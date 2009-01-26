class TrainyardController < ApplicationController
  def text_area_preview
    @text = params[:text]
    
    respond_to do |format|
      format.html { render :template => 'theme/text_area_preview', :layout => false }
    end
  end
end
