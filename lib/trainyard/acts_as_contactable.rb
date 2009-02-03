module Trainyard
  module ActsAsContactable
    def self.included(base)
      base.extend(MacroMethods)
    end
  
    module MacroMethods
      def acts_as_contactable(*args)
        options = args.extract_options!
        
        address_options = options.has_key?(:address) ? options[:address] : {}
        
        unless !address_options
          address_name = address_options.delete(:name) || :address
          
          class_eval do
            has_one address_name, address_options.reverse_merge(:as => :resource, :class_name => 'Address', :dependent => :destroy)

            has_accessible address_name

            attr_accessible address_name
          end
        end
        
        emails_options = options.has_key?(:emails) ? options[:emails] : {}
        
        unless !emails_options
          emails_name = emails_options.delete(:name) || :emails
          
          class_eval do
            has_many emails_name, emails_options.reverse_merge(:as => :resource, :class_name => 'Email', :dependent => :destroy)

            has_accessible emails_name

            attr_accessible emails_name
          end
        end
        
        phones_options = options.has_key?(:phones) ? options[:phones] : {}
        
        unless !phones_options
          phones_name = phones_options.delete(:name) || :phones
          
          class_eval do
            has_many phones_name, phones_options.reverse_merge(:as => :resource, :class_name => 'Phone', :dependent => :destroy)

            has_accessible phones_name

            attr_accessible phones_name
          end
        end
        
        urls_options = options.has_key?(:urls) ? options[:urls] : {}
        
        unless !urls_options
          urls_name = urls_options.delete(:name) || :urls
          
          class_eval do
            has_many urls_name, urls_options.reverse_merge(:as => :resource, :class_name => 'Url', :dependent => :destroy)

            has_accessible urls_name

            attr_accessible urls_name
          end
        end
      end
    end
  end
end

ActiveRecord::Base.send(:include, Trainyard::ActsAsContactable) if defined?(ActiveRecord::Base)