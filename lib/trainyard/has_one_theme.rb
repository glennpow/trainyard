module Trainyard
  module HasOneTheme
    def self.included(base)
      base.extend(MacroMethods)
    end
  
    module MacroMethods
      def has_one_theme(*args)
        options = args.extract_options!
        theme_name = args.first || :theme
      
        class_eval do
          has_one :themeables_theme, :as => :themeable, :dependent => :destroy
          has_one theme_name, :through => :themeables_theme
        end
      end
    end
  end
end

ActiveRecord::Base.send(:include, Trainyard::HasOneTheme) if defined?(ActiveRecord::Base)