class GroupsController < ApplicationController
  make_resource_controller do
    belongs_to :user
    
    before :new do
      @parent_groups = Group.find(:all)
    end
    
    before :edit do
      @parent_groups = Group.find(:all, :conditions => [ "id != ?", @group.id ]) - @group.child_groups
    end
  end
  
  def resourceful_name
    t(:group)
  end

  before_filter :check_administrator_role, :only => [ :index, :new, :create, :edit, :update, :destroy ]
  
  def index
    respond_with_indexer do |options|
      options[:default_sort] = :name
      options[:headers] = [
        { :name => t(:name), :sort => :name },
        t(:parent_group, :scope => [ :authentication ]),
        tp(:child_group, :scope => [ :authentication ]),
        t(:moderator, :scope => [ :authentication ]),
        tp(:user, :scope => [ :authentication ])
      ]
      options[:search] = true

      if @user
        options[:include] = :memberships
        options[:conditions] = [ "#{Membership.table_name}.user_id = ?", @user.id ]
      end
    end
  end
end
