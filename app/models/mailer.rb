class Mailer < ActionMailer::Base
  helper :trainyard
  
  def generic_email(options)
    self.class.default_url_options[:host] = site_email_host
    
    users = options[:users] || []
    users << options[:user] if options[:user]
    emails = options[:emails] || []
    emails << options[:email] if options[:email]
    
    users.each do |user|
      if options[:force_alert] || user.mailer_alerts
        emails << user.email
      end
    end
    
    if emails.any?
      recipients   emails
      from         "#{site_name} <#{site_email}>"
      subject      "#{site_name}#{options[:subject].nil? ? '' : ' - ' + options[:subject]}"
      sent_on      Time.now
      content_type "text/html"
      body         :body => options[:body] || ''
    end
  end
end
