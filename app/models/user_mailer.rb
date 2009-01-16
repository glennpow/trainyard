class UserMailer
  def self.deliver_signup_notification(user)
    Mailer.deliver_generic_email({ :user => user,
      :subject => I18n.t(:email_subject, :scope => [ :authenticate, :users, :new ]),
      :body => Proc.new { |template| template.auto_format(I18n.t(:email_body, :scope => [ :authenticate, :users, :new ], :login => user.login, :password => user.password,
        :url => template.url_for(:controller => 'users', :action => 'confirm', :id => user.perishable_token, :only_path => false))) }
    })
  end
  
  def self.deliver_confirmation(user)
    Mailer.deliver_generic_email({ :user => user,
      :subject => I18n.t(:email_subject, :scope => [ :authenticate, :users, :confirm ]),
      :body => Proc.new { |template| template.auto_format(I18n.t(:email_body, :scope => [ :authenticate, :users, :confirm ], :login => user.login,
        :url => template.url_for(:controller => 'site', :action => 'home', :only_path => false))) }
    })
  end
  
  def self.deliver_forgot_password(user)
    Mailer.deliver_generic_email({ :user => user,
      :subject => I18n.t(:email_subject, :scope => [ :authenticate, :passwords, :forgot ]),
      :body => Proc.new { |template| template.auto_format(I18n.t(:email_body, :scope => [ :authenticate, :passwords, :forgot ], :login => user.login,
        :url => template.url_for(:controller => 'users', :action => 'reset_password', :id => user.perishable_token, :only_path => false))) }
    })
  end
end
