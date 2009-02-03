module Trainyard
  module ActsAsResource
    def self.included(base)
      base.extend(MacroMethods)
    end
  
    module MacroMethods
      def acts_as_resource(*args)
        options = args.extract_options!
        
        group_options = options[:group] || {}
      
        case group_options
        when Proc
          define_method :group do
            group_options.call(self)
          end
        else
          group_options = {} unless group_options.is_a?(Hash)
          
          class_eval do
            if group_options[:through]
              has_one :group, group_options.reverse_merge(:source => :group)
            else
              belongs_to :group, group_options.reverse_merge(:class_name => 'Group')

              if group_options[:dependent] == :destroy
                has_accessible :group

                attr_writer :moderator
  
                def moderator
                  @moderator ||= self.group.moderators.first
                end
  
                attr_writer :parent_group
  
                def parent_group
                  @parent_group ||= self.group.parent_group
                end
    
                before_create :create_dependent_group

  
                private
  
                def create_dependent_group
                  if self.moderator
                    if self.group = Group.create(:name => self.name, :parent_group => self.parent_group)
                      self.moderator.assign_role!(Role.administrator, self.group)
                      self.moderator.assign_role!(Role.editor, self.group)
                      true
                    else
                      errors.add(:group, self.group.errors.full_messages.to_sentence) 
                      false
                    end
                  else
                    errors.add(:moderator, t(:failure_invalid_moderator, :scope => [ :authentication, :groups ]))
                    false
                  end
                end
              end
            end
          end
        end
  
        define_method :moderators do
          @moderators ||= self.group.moderators
        end

        permissions_options = options[:permissions] || {}
        
        class_eval do
          has_many :permissions, permissions_options.reverse_merge(:as => :resource, :dependent => :destroy)
          
          after_create :create_default_permissions
          
          def create_default_permissions
            unless self.group.nil?
              Permission.create(:group_id => self.group.id, :action_id => Action.edit.id, :role_id => Role.editor.id, :resource => self)
            end
          end
        end
        
        class_eval do
          has_many :watchings, permissions_options.reverse_merge(:as => :resource, :dependent => :destroy)
          has_many :watching_users, :through => :watchings, :source => :user
        end
      end
    end
  end
end

ActiveRecord::Base.send(:include, Trainyard::ActsAsResource) if defined?(ActiveRecord::Base)