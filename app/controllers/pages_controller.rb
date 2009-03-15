class PagesController < ApplicationController
  make_resource_controller do
    belongs_to :group
  end
  
  def resourceful_name
    t(:page, :scope => [ :content ])
  end

  before_filter :check_editor_of_group, :only => [ :index, :new, :create ]
  before_filter :check_editor_of_page, :only => [ :show, :edit, :update, :destroy ]
  
  def index
    respond_with_indexer do |options|
      options[:default_sort] = :name
      options[:headers] = [
        { :name => t(:name), :sort => :name },
        { :name => t(:permalink, :scope => [ :content ]), :sort => :permalink },
        t(:group, :scope => [ :authentication ]),
      ]
      options[:search] = true

      options[:conditions] = { :group_id => @group.id } if @group
    end
  end
  
  
  private
  
  def check_editor_of_group
    check_administrator_role || check_editor_of(@group)
  end
  
  def check_editor_of_page
    check_editor_of(@page)
  end
end
