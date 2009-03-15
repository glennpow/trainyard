class PortletController < ApplicationController
  before_filter :check_portal, :only => [ :portlet ]
  
  def portlet
    respond_to do |format|
      format.html { redirect_to Configuration.default_path }
      format.js
      format.xml  { head :ok }
    end
  end
  
  def reset_portlet
    reset_portal
    
    respond_to do |format|
      format.html { redirect_to :back }
      format.js   { redirect_to :back }
      format.xml  { head :ok }
    end
  end
  
  
  private
  
  def check_portal
    check_condition(parse_portal(params))
  end
end
