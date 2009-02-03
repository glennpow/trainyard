module Trainyard
  module ActsAsCommentable
    def self.included(base)
      base.extend(MacroMethods)
    end
  
    module MacroMethods
      def acts_as_commentable(*args)
        options = args.extract_options!
        comments_name = args.first || :comments
        
        class_eval do
          has_many comments_name, options.reverse_merge(:as => :resource, :class_name => 'Comment', :order => 'created_at ASC', :dependent => :destroy)
        end
      end
    end
  end
end

ActiveRecord::Base.send(:include, Trainyard::ActsAsCommentable) if defined?(ActiveRecord::Base)
