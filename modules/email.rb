module EMAIL
  include SendGrid

  def self.send
    current_date = Date.today.to_s(:long)
    mail = Mail.new
    mail.from = Email.new(email: 'nevillealee@gmail.com') #TODO:(Nevile Lee) Change to Crystals default email
    mail.subject = "Current collection inventory/subscription count as of #{current_date}"
    personalization = Personalization.new
    personalization.add_to(Email.new(email: 'nevillealee@gmail.com', name: 'Neville Lee'))
    # personalization.subject = 'Hello World from the Personalized SendGrid Ruby Library'
    mail.add_personalization(personalization)
    mail.add_content(Content.new(type: 'text/html', value: '<html><body>Please find the weekly report attached</body></html>'))

    attachment = Attachment.new
    attachment.content = Base64.strict_encode64(File.open(fpath, 'rb').read)
    attachment.type = 'application/vnd.oasis.opendocument.spreadsheet'
    attachment.filename = fname
    attachment.disposition = 'attachment'
    attachment.content_id = 'test Sheet'
    mail.add_attachment(attachment)

    sg = SendGrid::API.new(api_key: ENV['SENDGRID_API_KEY'], host: 'https://api.sendgrid.com')
    response = sg.client.mail._('send').post(request_body: mail.to_json)
    puts response.status_code
    puts response.body
    puts response.headers
  end
end #module
