class ThemesController < ApplicationController
  make_resource_controller do
    belongs_to :themeable
    
    member_actions :stylesheet
    
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

  before_filter :check_administrator_role, :only => [ :new, :create, :edit, :update, :destroy ]
  before_filter :check_editor_or_administrator, :only => [ :index, :apply ]

  def index
    respond_with_indexer do |options|
      options[:default_sort] = :name
      options[:headers] = [
        { :name => t(:name), :sort => :name },
        t(:active, :scope => [ :themes ])
      ]
      options[:search] = true
    end
  end
  
  def apply
    attributes = { :themeable_type => @themeable ? @themeable.class.to_s : nil, :themeable_id => @themeable ? @themeable.id : nil }
    themeable_theme = ThemeablesTheme.first(:conditions => attributes) || ThemeablesTheme.new(attributes)
    themeable_theme.theme_id = params[:id]
    if themeable_theme.save
      flash[:notice] = t(:object_updated, :object => resourceful_name)
    else
      flash[:error] = t(:object_not_updated, :object => resourceful_name)
    end
    redirect_to @themeable ? polymorphic_path([ @themeable, Theme.new ]) : themes_path
  end
  
  def preview
  end
  
  def stylesheet
    @theme.attributes=(params[:theme])
    
    respond_to do |format|
      format.css  # stylesheet.css.erb
    end
  end
 
  
  private
  
  def check_editor_or_administrator
    @themeable = params[:themeable_type].to_class.find(params[:themeable_id]) if params[:themeable_id] && params[:themeable_type]
    check_condition(has_administrator_role? || (@theme && @themeable && @themeable.respond_to?(:theme=) && is_editor_of?(@themeable)))
  end
end
