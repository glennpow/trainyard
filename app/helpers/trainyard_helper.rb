module TrainyardHelper
  def trainyard_header(options = {})
    concat(stylesheet_link_tag('trainyard', :plugin => 'trainyard'))
    case options[:theme]
    when String
      concat(stylesheet_link_tag_theme(options[:theme]))
    when false
    else
      concat(stylesheet_link_tag_theme)
    end
    unless options[:ajax] == false
      concat(javascript_include_tag('lowpro', :plugin => 'trainyard'))
      concat(javascript_include_tag('behaviors', :plugin => 'trainyard'))
    end
    concat(stylesheet_link_tag('indexer', :plugin => 'indexer'))
  end
end
