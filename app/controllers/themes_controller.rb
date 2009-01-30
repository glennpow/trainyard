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
    if @themeable.nil?
      themeable_theme = ThemeablesTheme.first(:conditions => { :themeable_type => nil, :themeable_id => nil }) || ThemeablesTheme.new
      themeable_theme.theme = @theme
      if themeable_theme.save
        flash[:notice] = t(:object_updated, :object => t(:theme, :scope => [ :content ]))
      else
        flash[:error] = t(:object_not_updated, :object => t(:theme, :scope => [ :content ]))
      end
    else
      if @themeable.update_attribute(:theme, @theme)
        flash[:notice] = t(:object_updated, :object => resourceful_name)
      else
        flash[:error] = t(:object_not_updated, :object => resourceful_name)
      end
      redirect_to polymorphic_path([ @themeable, Theme.new ])
    end
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
