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
  
  def head(content)
    content_for(:head) { content }
  end

  def javascript(*files)
    content_for(:head) { javascript_include_tag(*files) }
  end
  
  def stylesheet(*files)
    content_for(:head) { stylesheet_link_tag(*files) }
  end
  
  def title(title = nil)
    @title = "#{Configuration.application_name}#{title.blank? ? '' : " - #{title}"}"
    content_for(:title) { @title }
  end
  
  def random_id(length = 8)
    chars = ("a".."z").to_a + ("A".."Z").to_a + [ "_" ]
    id = chars[rand(chars.size - 1)]
    chars += ("0".."9").to_a
    2.upto(length) { |i| id << chars[rand(chars.size - 1)] }
    return id
  end
  
  def url_escape(string)
    URI.escape(CGI.escape(string),'.')
  end
  
  def check_param(keys, default = nil)
    hash = params
    [ keys ].flatten.each do |key|
      hash = hash[key]
      break if hash.nil?
    end
    hash.nil? ? default : hash
  end

  def auto_format(text)
    textilize(auto_link(text))
  end

  def link_to_textile_hint
    t(:text_style_hint, :scope => [ :site_content ],
      :link => link_to("Textile", "http://redcloth.org/textile", :target => "_blank"))
  end
end
