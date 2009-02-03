module Trainyard
  module ActsAsReviewable
    def self.included(base)
      base.extend(MacroMethods)
    end
  
    module MacroMethods
      def acts_as_reviewable(*args)
        options = args.extract_options!
        reviews_name = args.first || :reviews
        
        class_eval do
          has_many reviews_name, options.reverse_merge(:as => :resource, :class_name => 'Review', :order => 'created_at ASC', :dependent => :destroy)
        end
      end
    end
  end
end

ActiveRecord::Base.send(:include, Trainyard::ActsAsReviewable) if defined?(ActiveRecord::Base)
