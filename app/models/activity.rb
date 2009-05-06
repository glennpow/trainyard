class Activity < ActiveRecord::Base
  belongs_to :user
  belongs_to :resource, :polymorphic => true
  
  validates_presence_of :user, :resource
  
  def self.track(options = {})
    throw_exceptions = options[:throw_exceptions] || false

    users = options[:users] || []
    users << options[:user] if options[:user]

    if users.any?
      users.each do |user|
        if throw_exceptions
          create!(:user => user, :resource => options[:resource], :message => options[:message], :public => options[:public])
        else
          return false unless create(:user => user, :resource => options[:resource], :message => options[:message], :public => options[:public])
        end
      end

      if options[:mail] && options[:message]
        if options[:mail] == true
          subject = body = options[:message]
        elsif options[:mail].is_a?(Hash)
          subject = options[:mail][:subject]
          body = options[:mail][:body]
        end
      
        Mailer.deliver_generic_email(:users => users, :subject => subject, :body => body)
      end
    end

    true
  end
  
  def self.track!(options = {})
    track(options.merge(:throw_exceptions => true))
  end
end