class Mailer < ActionMailer::Base
  helper :trainyard
  
  def generic_email(options)
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
      from         "#{Configuration.application_name} <#{Configuration.application_mail}@#{Configuration.application_domain}>"
      subject      "#{Configuration.application_name}#{options[:subject].nil? ? '' : ' - ' + options[:subject]}"
      sent_on      Time.now
      content_type "text/html"
      body         :body => options[:body] || ''
    end
  end
end
