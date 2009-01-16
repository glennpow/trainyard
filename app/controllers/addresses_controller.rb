class AddressesController < ApplicationController
  def update_regions
    select_id = params[:select_id]
    country = Country.find(params[:country_id])
    regions = country.regions

    render :update do |page|
      if regions.any?
        page.replace_html select_id, :partial => 'regions', :locals => { :regions => regions }
        page.show select_id
      else
        page.replace_html select_id, ""
        page.show text_id
      end
    end
  end
end
