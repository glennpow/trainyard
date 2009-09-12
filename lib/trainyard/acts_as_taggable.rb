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
        taggings_name = "#{tags_name}_taggings"
        
        class_eval do
          has_many taggings_name.intern, :as => :resource, :class_name => 'Tagging', :include => :tag, :order => 'created_at ASC', :dependent => :destroy
          has_many tags_name.intern, :through => taggings_name, :class_name => 'Tag', :source => :tag, :order => 'name ASC'
          
          before_save "save_#{tags_name}"
          
          define_method "#{tag_name}_names" do
            self.send(tags_name).map(&:name)
          end
          
          define_method "#{tag_name}_list" do |*args|
            separator = args.first || ', '
            self.send("#{tag_name}_names").join(separator)
          end
          
          define_method "save_#{tags_name}" do
          end
        end
      end
    end
  end
end

ActiveRecord::Base.send(:include, Trainyard::ActsAsTaggable) if defined?(ActiveRecord::Base)
