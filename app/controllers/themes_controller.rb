class ThemesController < ApplicationController
  make_resourceful do
    belongs_to :themeable
    
    member_actions :apply, :stylesheet
    
    before :new do
      (@theme.attribute_names - [ 'name' ]).each { |attr| @theme.send("#{attr}=", current_theme.send(attr)) }
    end
  end
  
  def resourceful_name
    t(:theme, :scope => [ :themes ])
  end

  def instance_variable_name
    'theme'
  end

  before_filter :login_required, :only => [ :apply ]
  before_filter :check_administrator_role, :only => [ :new, :create, :edit, :update, :destroy ]
  before_filter :check_editor_of_themeable, :only => [ :apply ]

  def index
    respond_with_indexer do |options|
      options[:default_sort] = :name
      if @themeable
        options[:headers] = [
          { :name => t(:name), :sort => :name },
          t(:active, :scope => [ :themes ])
        ]
      else
        options[:headers] = [
          { :name => t(:name), :sort => :name }
        ]
      end
      options[:search] = true
    end
  end
  
  def apply
    if @themeable.update_attribute(:theme, @theme)
      flash[:notice] = t(:object_updated, :object => resourceful_name)
    else
      flash[:error] = t(:object_not_updated, :object => resourceful_name)
    end
    redirect_to polymorphic_path([ @themeable, Theme.new ])
  end
  
  def preview
    respond_to do |format|
      format.html do
        strip_links do
          render :controller => 'users', :action => 'show'
        end
      end
    end
  end
  
  def stylesheet
    @theme.attributes=(params[:theme])
    
    respond_to do |format|
      format.css  # stylesheet.css.erb
    end
  end
 
  
  private
  
  def check_editor_of_themeable
    @themeable = params[:themeable_type].to_class.find(params[:themeable_id]) if params[:themeable_id] && params[:themeable_type]
    check_condition(@theme && @themeable && @themeable.respond_to?(:theme) && is_editor_of?(@themeable))
  end
end
