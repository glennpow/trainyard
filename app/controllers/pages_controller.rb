class PagesController < ApplicationController
  make_resourceful do
    belongs_to :group
  end
  
  def resourceful_name
    t(:page, :scope => [ :content ])
  end

  before_filter :login_required, :only => [ :index, :show, :new, :create, :edit, :update, :destroy ]
  before_filter :check_editor_of, :only => [ :index, :show, :new, :create, :edit, :update, :destroy ]
  
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
  
  def check_editor_of
    check_editor(@group || @page)
  end
end
