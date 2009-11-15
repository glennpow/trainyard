module Trainyard
  module HasManyTags
    def self.included(base)
      base.extend(MacroMethods)
    end
  
    module MacroMethods
      def has_many_tags(*args)
        options = args.extract_options!
        tags_name = args.first || "tags"
        tag_name = tags_name.singularize
        tags_taggings_name = "#{tags_name}_taggings"
        tag_names_name = "#{tag_name}_names"
        tag_list_name = "#{tag_name}_list"
        save_tags_name = "save_#{tags_name}"
        
        class_eval do
          has_many tags_taggings_name.intern, :as => :resource, :class_name => 'Tagging', :include => :tag, :order => 'created_at ASC', :dependent => :destroy
          has_many tags_name.intern, :through => tags_taggings_name.intern, :class_name => 'Tag', :source => :tag, :order => 'name ASC'
          
          before_save save_tags_name
          
          define_method tag_names_name do
            self.send(tags_name).map(&:name)
          end
          
          define_method tag_list_name do |*args|
            separator = args.first || ', '
            self.send(tag_names_name).join(separator)
          end
          
          define_method save_tags_name do
          end
        end
      end
    end
  end
end

ActiveRecord::Base.send(:include, Trainyard::HasManyTags) if defined?(ActiveRecord::Base)
