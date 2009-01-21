class GroupsController < ApplicationController
  make_resourceful do
    belongs_to :user
    
    before :new do
      @parent_groups = Group.find(:all)
    end
    
    before :edit do
      @parent_groups = Group.find(:all, :conditions => ["id != ?", @group.id]) - @group.child_groups
    end
  end
  
  def resourceful_name
    t(:group, :scope => [ :authentication ])
  end

  before_filter :check_administrator_role, :only => [ :index, :new, :create, :edit, :update, :destroy ]
  
  def index
    respond_with_indexer do |options|
      options[:default_sort] = :name
      options[:headers] = [
        { :name => t(:name), :sort => :name, :order => 'groups.name' },
        t(:parent_group, :scope => [ :authentication ]),
        tp(:child_group, :scope => [ :authentication ]),
        t(:moderator, :scope => [ :authentication ]),
        tp(:user, :scope => [ :authentication ])
      ]
      options[:search] = true

      if @user
        options[:include] = :users
        options[:conditions] = [ 'users.id = ? OR moderator_id = ?', @user.id, @user.id ]
      end
    end
  end
end
