require_relative '../lib/recharge_active_record'
require_relative '../lib/async'
require_relative 'application_record'
require_relative 'sub_line_item'

class Subscription < ActiveRecord::Base
  include ApplicationRecord
  include Async

  self.primary_key = :subscription_id

  belongs_to :customer
  has_many :line_items, class_name: 'SubLineItem'
  # has_many :order_line_items, class_name: 'OrderLineItemsFixed'
  # has_many :orders, through: :order_line_items
  # has_and_belongs_to_many :charges, join_table: 'charge_fixed_line_items'

  after_save :update_line_items

  # the options this method takes are:
  # * :time - a valid datetime string / object
  # * :theme_id - the theme the product tag is associated with
  def self.current_products(options = {})
    where(shopify_product_id: ProductTag.active(options).where(tag: 'current').pluck(:product_id))
  end

  # the options this method takes are:
  # * :time - a valid datetime string / object
  # * :theme_id - the theme the product tag is associated with
  def self.prepaid_products(options = {})
    where(shopify_product_id: ProductTag.active(options).where(tag: 'prepaid').pluck(:product_id))
  end

  # the options this method takes are:
  # * :time - a valid datetime string / object
  # * :theme_id - the theme the product tag is associated with
  def self.skippable_products(options = {})
    where(shopify_product_id: ProductTag.active(options).where(tag: 'skippable').pluck(:product_id))
  end

  # the options this method takes are:
  # * :time - a valid datetime string / object
  # * :theme_id - the theme the product tag is associated with
  def self.switchable_products(options = {})
    switchable_products = ProductTag.active(options)
      .where(tag: 'switchable')
      .pluck(:product_id)
    where(shopify_product_id: switchable_products)
  end

  # Defines the relationship between the local database table and the remote
  # Recharge data format
  def self.api_map
    # helper functions
    identity = ->(x) { x }
    to_s = ->(x) { x.to_s }
    to_i = ->(x) { x.to_i }
    recharge_time = ->(time) { time.try(:strftime, '%FT%T') }
    to_time = ->(str) { str.nil? ? nil : Time.parse(str) }
    to_f = ->(x) { x.to_f }
    [
      {
        remote_key: 'id',
        local_key: 'subscription_id',
        inbound: identity,
        outbound: to_i,
      },
      {
        remote_key: 'address_id',
        local_key: 'address_id',
        inbound: identity,
        outbound: to_i,
      },
      {
        remote_key: 'customer_id',
        local_key: 'customer_id',
        inbound: identity,
        outbound: to_i,
      },
      {
        remote_key: 'created_at',
        local_key: 'created_at',
        inbound: to_time,
        outbound: recharge_time,
      },
      {
        remote_key: 'updated_at',
        local_key: 'updated_at',
        inbound: to_time,
        outbound: recharge_time,
      },
      {
        remote_key: 'next_charge_scheduled_at',
        local_key: 'next_charge_scheduled_at',
        inbound: to_time,
        outbound: recharge_time,
      },
      {
        remote_key: 'cancelled_at',
        local_key: 'cancelled_at',
        inbound: to_time,
        outbound: recharge_time,
      },
      {
        remote_key: 'product_title',
        local_key: 'product_title',
        inbound: identity,
        outbound: identity,
      },
      {
        remote_key: 'price',
        local_key: 'price',
        inbound: identity,
        outbound: identity,
      },
      {
        remote_key: 'quantity',
        local_key: 'quantity',
        inbound: identity,
        outbound: identity,
      },
      {
        remote_key: 'status',
        local_key: 'status',
        inbound: identity,
        outbound: identity,
      },
      {
        remote_key: 'shopify_product_id',
        local_key: 'shopify_product_id',
        inbound: identity,
        outbound: to_i,
      },
      {
        remote_key: 'shopify_variant_id',
        local_key: 'shopify_variant_id',
        inbound: identity,
        outbound: to_i,
      },
      {
        remote_key: 'sku',
        local_key: 'sku',
        inbound: identity,
        outbound: identity,
      },
      {
        remote_key: 'order_interval_unit',
        local_key: 'order_interval_unit',
        inbound: identity,
        outbound: identity,
      },
      {
        remote_key: 'order_interval_frequency',
        local_key: 'order_interval_frequency',
        inbound: identity,
        outbound: identity,
      },
      {
        remote_key: 'order_day_of_month',
        local_key: 'order_day_of_month',
        inbound: identity,
        outbound: identity,
      },
      {
        remote_key: 'order_day_of_week',
        local_key: 'order_day_of_week',
        inbound: identity,
        outbound: identity,
      },
      {
        remote_key: 'properties',
        local_key: 'raw_line_item_properties',
        inbound: lambda do |p|
          logger.debug "parsing properties: #{p}"
          p || []
        end,
        outbound: identity,
      },
    ].freeze
  end

  # skips the given subscription_id immeadiately
  # returns the updated active record object.
  def self.skip!(subscription_id)
    sub = Subscription.find(subscription_id)
    res = sub.skip
    return unless res[0]
    sub.recharge_update!
  end

  def prepaid?
    ProductTag.active.where(tag: 'prepaid').pluck(:product_id).include? shopify_product_id
  end

  def active?(time = nil)
    time ||= Time.current
    next_charge_scheduled_at.try('>', time) &&
      status == 'ACTIVE'
  end

  # evaluated options are:
  #   time: the time of the skip action
  #   theme_id: the theme_id for checking appropriate ProductTags
  def skippable?(options = {})
    now = options[:time] || Time.zone.now
    skip_conditions = [
      !prepaid?,
      active?,
      now.day < 5,
      ProductTag.active(options).where(tag: 'skippable')
        .pluck(:product_id).include?(shopify_product_id),
      next_charge_scheduled_at.try('>', now.beginning_of_month),
      next_charge_scheduled_at.try('<', now.end_of_month),
      next_charge_scheduled_at.try('>', now),
    ]
    skip_conditions.all?
  end

  def skip
    return false unless skippable?
    self.next_charge_scheduled_at += 1.month
    save
  end

  #def charges
    #Charge.by_subscription_id subscription_id
  #end

  def next_charge(time = nil)
    time ||= Time.current
    charges.where('scheduled_at > ?', time)
      .order(scheduled_at: :asc)
      .first
  end

  def shipping_at
    next_order = orders.where(status: 'QUEUED')
      .where('scheduled_at > ?', Date.today)
      .order(:scheduled_at)
      .first
    next_order.try(&:scheduled_at)
  end

  def size_line_items
    line_items.where(name: SubLineItem::SIZE_PROPERTIES)
  end

  def sizes
    raw_line_item_properties
      .select{|p| SubLineItem::SIZE_PROPERTIES.include? p['name']}
      .map{|p| [p['name'], p['value']]}
      .to_h
  end

  def sizes=(new_sizes)
    prop_hash = raw_line_item_properties.map{|prop| [prop['name'], prop['value']]}.to_h
    merged_hash = prop_hash.merge new_sizes
    puts "merged_hash = #{merged_hash}"
    self[:raw_line_item_properties] = merged_hash.map{|k, v| {'name' => k, 'value' => v}}
  end

  # valid options are:
  #   time: the time the switch was made (used for checking company policy)
  #   theme_id: the theme_id used for finding switchable and alternate products
  def switchable?(options = {})
    now = options[:time] || Time.zone.now
    switch_conditions = [
      !prepaid?,
      active?,
      ProductTag.active(options).where(tag: 'switchable')
        .pluck(:product_id).include?(shopify_product_id),
      next_charge_scheduled_at.try('>', now.beginning_of_month),
      next_charge_scheduled_at.try('<', now.end_of_month),
      next_charge_scheduled_at.try('>', now),
    ]
    switch_conditions.all?
  end

  # valid options are:
  #   time: the time the switch was made (used for checking company policy)
  #   theme_id: the theme_id used for finding switchable and alternate products
  def switch_product(new_product_id = nil, options = {})
    return false unless switchable?(options)
    self.shopify_product_id = new_product_id || alt_product_id
    save
  end

  def self.get_alt_product_id(current_product_id)
    Config['alt_products'][current_product_id]
  end

  def alt_product_id
    Subscription.get_alt_product_id product_id
  end

  def current_product?
    ProductTag.active.where(tag: 'current').pluck(:product_id).include? shopify_product_id
  end

  private

  def update_line_items
    return unless saved_change_to_attribute? :raw_line_item_properties
    Subscription.transaction do
      raw_line_item_properties.each do |prop|
        sub = SubLineItem.find_or_create_by(
          subscription_id: subscription_id,
          name: prop[:name],
        )
        sub.value = prop[:value]
        sub.save!
      end
    end
  end

end
