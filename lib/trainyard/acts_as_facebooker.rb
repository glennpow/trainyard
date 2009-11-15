module Trainyard
  module ActsAsFacebooker
    def self.included(base)
      base.extend(MacroMethods)
    end
  
    module MacroMethods
      def acts_as_facebooker(*args)
        options = args.extract_options!
        fb_user_name = options[:user] || :fb_user
        fb_email_hash_name = options[:email_hash] || :email_hash

        #find the user in the database, first by the facebook user id and if that fails through the email hash
        meta_def "find_by_#{fb_user_name}" do |fb_user| #(class << self; self; end)
          metaclass.find_by_fb_user_id(fb_user.uid) || metaclass.find_by_email_hash(fb_user.email_hashes) if fb_user
        end

        #Take the data returned from facebook and create a new user from it.
        #We don't get the email from Facebook and because a facebooker can only login through Connect we just generate a unique login name for them.
        #If you were using username to display to people you might want to get them to select one after registering through Facebook Connect
        meta_def "create_from_fb_connect" do |fb_user|
          new_facebooker = metaclass.new(:name => fb_user.name, :login => "facebooker_#{fb_user.uid}", :password => "", :email => "")
          new_facebooker.send("#{fb_user_name}_id=", fb_user.uid.to_i)
          #We need to save without validations
          new_facebooker.save(false)
          new_facebooker.register_user_to_fb
        end
        
        class_eval do
          after_create :register_user_to_fb

          #We are going to connect this user object with a facebook id. But only ever one account.
          def link_fb_connect(fb_user_id)
            unless fb_user_id.nil?
              #check for existing account
              existing_fb_user = metaclass.send("find_by_#{fb_user_name}", fb_user_id)
              #unlink the existing account
              unless existing_fb_user.nil?
                existing_fb_user.send("#{fb_user_name}_id=", nil)
                existing_fb_user.save(false)
              end
              #link the new one
              self.send("#{fb_user_name}_id=", fb_user_id)
              save(false)
            end
          end

          #The Facebook registers user method is going to send the users email hash and our account id to Facebook
          #We need this so Facebook can find friends on our local application even if they have not connect through connect
          #We hen use the email hash in the database to later identify a user from Facebook with a local user
          def register_user_to_fb
            users = {:email => email, :account_id => id}
            Facebooker::User.register([users])
            self.send("#{fb_email_hash_name}=", Facebooker::User.hash_email(email))
            save(false)
          end
  
          def facebook_user?
            return !self.send("#{fb_user_name}_id").nil? && self.send("#{fb_user_name}_id") > 0
          end
        end
      end
    end
  end
end

ActiveRecord::Base.send(:include, Trainyard::ActsAsFacebooker) if defined?(ActiveRecord::Base)
