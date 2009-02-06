class AddressesController < ApplicationController
  before_filter :check_resource_type, :only => [ :locate, :locate_results ]
  before_filter :check_address, :only => [ :locate_results ]

  def update_regions
    render :update do |page|
      unless params[:select_id].blank? || params[:country_id].blank?
        select_id = params[:select_id]
        country = Country.find(params[:country_id])
        regions = country.regions

        if regions.any?
          page.replace_html select_id, :partial => 'regions', :locals => { :regions => regions }
        else
          page.replace_html select_id, ""
        end
      end
    end
  end
  
  def locate
    @address = logged_in? ? current_user.address : Address.new
    
    respond_to do |format|
      format.html # locate.html.erb
      format.xml  { head :ok }
    end
  end
  
  def locate_results
    respond_with_indexer(Address) do |options|
      options[:per_page] ||= 10
      options[:as] = :resource
      options[:row] = "addresses/locate_row"
      options[:no_table] = true

      options[:origin] = [ @latitude.to_f, @longitude.to_f ]
      options[:order] = "#{Address.distance_column_name} ASC"
      options[:within] = params[:within]
      options[:conditions] = [ "#{Address.table_name}.resource_type = ?", @resource_type ]
      options[:post_process] = Proc.new { |collection| collection.map!(&:resource) }
    end
  end
  
  
  private
  
  def check_resource_type
    check_condition(@resource_type = params[:resource_type])
  end
  
  def check_address
    @latitude = nil
    @longitude = nil
    if !params[:latitude].blank? && !params[:longitude].blank?
      @latitude = params[:latitude]
      @longitude = params[:longitude]
    elsif params[:user_address] && logged_in?
      if @address = current_user.address
        @latitude = @address.latitude
        @longitude = @address.longitude
      end
    elsif params[:address]
      @address = Address.new(params[:address])
      if @address.locate
        @latitude = @address.latitude
        @longitude = @address.longitude
      end
    end
    if @latitude.blank? || @longitude.blank?
      flash[:error] = t(:invalid_address, :scope => [ :contacts ])
      respond_to do |format|
        format.html { render :action => 'locate' }
      end
      return false
    end
  end
end
