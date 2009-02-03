class OrganizationsController < ApplicationController
  make_resource_controller do
    belongs_to :group
    
    member_actions :set_current
    
    before :create do
      @organization.moderator = current_user
      @organization.parent_group = @group
    end
    
    response_for :create do |format|
      format.html { redirect_to home_path }
    end
    
    response_for :update do |format|
      format.html { redirect_to home_path }
    end
  end
  
  def resourceful_name
    t(:organization, :scope => [ :authorization ])
  end

  before_filter :check_add_organization, :only => [ :new, :create ]
  before_filter :check_moderator_of, :only => [ :edit, :update, :destroy ]
  before_filter :check_editor_of, :only => [ :set_current ]
  
  def index
    respond_with_indexer do |options|
      options[:default_sort] = :name
      options[:headers] = [
        { :name => t(:name), :sort => :name },
        tp(:moderator, :scope => [ :authentication ]),
      ]
      options[:search] = true
    end
  end
  
  def set_current
    self.current_organization = @organization
    
    respond_to do |format|
      format.html { redirect_to :back }
    end
  end
  
  
  private
  
  def check_add_organization
    check_condition(has_permission?(Action.add_organization, @group))
  end
  
  def check_moderator_of
    check_moderator(@organization)
  end
  
  def check_editor_of
    check_editor(@organization)
  end
end
