module EMAIL
  include SendGrid
  # Public: method for sending inventory email to customer service
  # All methods are module methods and should be called on the EMAIL module
  #
  # Examples
  #   rake email:send
  #   # => :send
  #        202
  def self.send
    current_date = Date.today.to_s(:long)
    mail = Mail.new
    mail.from = Email.new(email: 'inventory@ellie.com')
    mail.subject = "Current collections inventory/subscription count as of #{current_date}"

    personalization1 = Personalization.new
    personalization1.add_to(Email.new(email: 'CWestbrook@fambrands.com', name: 'Crystal Westbrook'))
    mail.add_content(Content.new(type: 'text/html', value: '<html><body>Please find ellie.com weekly inventory report attached</body></html>'))
    mail.add_personalization(personalization1)

    personalization2 = Personalization.new
    personalization2.add_to(Email.new(email: 'TTiao@fambrands.com', name: 'Tracy Tiao'))
    mail.add_content(Content.new(type: 'text/html', value: '<html><body>Please find ellie.com weekly inventory report attached</body></html>'))
    mail.add_personalization(personalization2)

    personalization3 = Personalization.new
    personalization3.add_to(Email.new(email: 'Evillegas@Fambrands.com', name: 'Elvira Villegas'))
    mail.add_content(Content.new(type: 'text/html', value: '<html><body>Please find ellie.com weekly inventory report attached</body></html>'))
    mail.add_personalization(personalization3)

    attachment = Attachment.new
    attachment.content = Base64.strict_encode64(File.open('./inventory_difference.csv', 'rb').read)
    attachment.type = 'text/csv'
    attachment.filename = 'inventory_difference.csv'
    attachment.disposition = 'attachment'
    attachment.content_id = 'Csv Sheet'
    mail.add_attachment(attachment)

    sg = SendGrid::API.new(api_key: ENV['SENDGRID_API_KEY'], host: 'https://api.sendgrid.com')
    response = sg.client.mail._('send').post(request_body: mail.to_json)
    puts response.status_code
    puts response.body
    puts response.headers
  end
end #module
