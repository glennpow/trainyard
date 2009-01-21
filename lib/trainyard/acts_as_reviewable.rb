module Trainyard
  module ActsAsReviewable
    def self.included(base)
      base.extend(MacroMethods)
    end
  
    module MacroMethods
      def acts_as_reviewable(*args)
        name = args.first || :reviews
        
        class_eval do
          has_many name, :as => :resource, :class_name => 'Review', :order => 'created_at ASC', :dependent => :destroy
        end
      end
    end
  end
end

ActiveRecord::Base.send(:include, Trainyard::ActsAsReviewable) if defined?(ActiveRecord::Base)
