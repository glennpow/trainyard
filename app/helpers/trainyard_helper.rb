module TrainyardHelper
  def trainyard_header(options = {})
    returning('') do |content|
      content << stylesheet_link_tag('indexer', :plugin => 'indexer')
      content << stylesheet_link_tag('trainyard', :plugin => 'trainyard')
      case options[:theme]
      when String
        content << stylesheet_link_tag_theme(options[:theme])
      when false
      else
        content << stylesheet_link_tag_theme
      end
      unless options[:ajax] == false
        content << javascript_include_tag('lowpro', :plugin => 'trainyard')
        content << javascript_include_tag('behaviors', :plugin => 'trainyard')
      end
    end
  end

  def current_site
    return @current_site if defined?(@current_site)
    @current_site = Configuration.sites.detect { |site| site[:domain] == request.domain } || Configuration.sites.first
    logger.debug "Application domain: #{request.domain} (#{@current_site[:name]})"
    @current_site
  end

  def site_name
    current_site[:name]
  end

  def site_email
    current_site[:email]
  end
  
  def site_email_host
    current_site[:email_host]
  end
end
