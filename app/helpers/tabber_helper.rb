module TabberHelper
  def tabber_init
    javascript 'tabber', :plugin => 'trainyard'
  end
  
  def tabber_tag(&block)
    content_tag :div, :class => 'tabber', &block
  end
  
  def tabber_tab_tag(options = {}, &block)
    content_tag :div, :class => "tabbertab#{options[:default] ? ' tabbertabdefault' : ''}", :title => options[:title], &block
  end
end