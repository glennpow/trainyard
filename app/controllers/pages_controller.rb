class PagesController < ApplicationController
  make_resourceful do
    belongs_to :group
  end
  
  def resourceful_name
    t(:page, :scope => [ :content ])
  end

  before_filter :login_required, :only => [ :new, :create, :edit, :update, :destroy ]
  before_filter :check_administrator_role
  before_filter :check_editor_of, :only => [ :new, :create, :edit, :update, :destroy ]
  
  def index
    respond_with_indexer do |options|
      options[:default_sort] = :name
      options[:headers] = [
        { :name => t(:name), :sort => :name },
        { :name => t(:permalink, :scope => [ :content ]), :sort => :permalink },
        { :name => t(:group, :scope => [ :authenticate ]), :sort => :group, :include => :group, :order => 'groups.name' },
      ]
      options[:search] = true
    end
  end


  private
  
  def check_editor_of
    check_editor(@group || @page)
  end
end
