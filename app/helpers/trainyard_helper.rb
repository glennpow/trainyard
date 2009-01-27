module TrainyardHelper
  def trainyard_header(options = {})
    returning('') do |content|
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
      content << stylesheet_link_tag('indexer', :plugin => 'indexer')
    end
  end
end