class Mailer < ActionMailer::Base
  helper :trainyard
  
  def generic_email(options)
    self.class.default_url_options[:host] = Configuration.current_site[:email_host]
    
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
      from         "#{Configuration.current_site[:name]} <#{Configuration.current_site[:email]}>"
      subject      "#{Configuration.current_site[:name]} <#{Configuration}#{options[:subject].nil? ? '' : ' - ' + options[:subject]}"
      sent_on      Time.now
      content_type "text/html"
      body         :body => options[:body] || ''
    end
  end
end
