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
          address_name = (address_options.is_a?(Hash) ? address_options.delete(:name) : address_options) || :address
          
          class_eval do
            has_one address_name, (address_options.is_a?(Hash) ? address_options : {}).reverse_merge(:as => :resource, :class_name => 'Address', :dependent => :destroy)

            accepts_nested_attributes_for address_name, :allow_destroy => true
          end
        end
        
        emails_options = options.has_key?(:emails) ? options[:emails] : {}
        
        unless !emails_options
          emails_name = (emails_options.is_a?(Hash) ? emails_options.delete(:name) : emails_options) || :emails
          
          class_eval do
            has_many emails_name, (emails_options.is_a?(Hash) ? emails_options : {}).reverse_merge(:as => :resource, :class_name => 'Email', :dependent => :destroy)

            accepts_nested_attributes_for emails_name, :allow_destroy => true
          end
        end
        
        phones_options = options.has_key?(:phones) ? options[:phones] : {}
        
        unless !phones_options
          phones_name = (phones_options.is_a?(Hash) ? phones_options.delete(:name) : phones_options) || :phones
          
          class_eval do
            has_many phones_name, (phones_options.is_a?(Hash) ? phones_options : {}).reverse_merge(:as => :resource, :class_name => 'Phone', :dependent => :destroy)

            accepts_nested_attributes_for phones_name, :allow_destroy => true
          end
        end
        
        urls_options = options.has_key?(:urls) ? options[:urls] : {}
        
        unless !urls_options
          urls_name = (urls_options.is_a?(Hash) ? urls_options.delete(:name) : urls_options) || :urls
          
          class_eval do
            has_many urls_name, (urls_options.is_a?(Hash) ? urls_options : {}).reverse_merge(:as => :resource, :class_name => 'Url', :dependent => :destroy)

            accepts_nested_attributes_for urls_name, :allow_destroy => true
          end
        end
      end
    end
  end
end

ActiveRecord::Base.send(:include, Trainyard::ActsAsContactable) if defined?(ActiveRecord::Base)