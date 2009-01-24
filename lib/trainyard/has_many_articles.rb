module Trainyard
  module HasManyArticles
    def self.included(base)
      base.extend(MacroMethods)
    end
  
    module MacroMethods
      def has_many_articles(*args)
        options = args.extract_options!
        articles_name = args.first || :articles
        revisionable_articles = options.delete(:revisionable)
      
        class_eval do
          has_many articles_name, options.reverse_merge(:as => :resource, :order => 'name ASC', :dependent => :destroy) do
            def active
              @active_wiki_articles ||= find(:all, :conditions => { :erased => false })
            end
          end

          def create_default_permissions_with_articles
            create_default_permissions_without_articles
            Permission.create(:group_id => self.group_id, :action_id => Action.add_article.id, :role_id => Role.editor.id, :resource => self)
          end
          alias_method_chain :create_default_permissions, :articles
        end

        define_method :edited_at do
          @edited_at ||= (self.send(articles_name).sort(&:updated_at).last || self).updated_at
        end
            
        unless revisionable_articles.nil?
          define_method :revisionable_articles? do
            revisionable_articles
          end
        end

        define_method :all_articles do
          all_articles = []
          child_articles = self.send(articles_name)
          while child_articles.any?
            all_articles += child_articles
            child_articles = child_articles.map { |article| article.child_articles }.flatten
          end
          all_articles
        end
      end
    end
  end
end

ActiveRecord::Base.send(:include, Trainyard::HasManyArticles) if defined?(ActiveRecord::Base)