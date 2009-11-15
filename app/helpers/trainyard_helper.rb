module TrainyardHelper
  def trainyard_header(options = {})
    returning('') do |content|
      content << indexer_header(options)
      content << stylesheet_link_tag('trainyard', :plugin => 'trainyard')
      case options[:theme]
      when String
        content << stylesheet_link_tag_theme(options[:theme])
      when false
      else
        content << stylesheet_link_tag_theme
      end
      unless options[:javascript] == false
        unless options[:lowpro] == false
          content << javascript_include_tag('lowpro', :plugin => 'trainyard')
          content << javascript_include_tag('behaviors', :plugin => 'trainyard')
        end
        content << javascript_include_tag('hint_window', :plugin => 'trainyard')
      end
    end
  end
end
