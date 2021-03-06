module PortletHelper
  def portlet_header
    if current_portal
      "<script type='text/javascript'>if (top == self) { self.location.href = '#{reset_portlet_path}' }</script>" unless default_portal?
    end
  end

  def portlet_frame_tag(portal, options = {})
    width = options[:width] || 900
    height = options[:height] || 600
    
    "<iframe src='http://#{request.domain}/portlet/#{portal.class.to_s.underscore}/#{portal.id}' width='#{width}' height='#{height}'></iframe>"
  end
end