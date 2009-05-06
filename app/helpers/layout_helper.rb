module LayoutHelper
  def merge_classes(*args)
    args.join(' ')
  end
  
  def named_anchor(name, content)
    "<a name='#{name}'></a>#{content}"
  end
  
  def link_to_back(name = nil)
    name ||= t(:back)
    link_to name, :back, :class => 'back'
  end
  
  def button_to_back(name = nil)
    name ||= t(:back)
    button_to name, :back, :class => 'back'
  end

  def render_flash
    returning('') do |content|
      flash.each do |key, value|
        content << render(:partial => 'layout/flash', :locals => { :type => key, :message => value })
      end
    end
  end
  
  def image_link_to(image_src, name, options = {}, html_options = {})
    html_options[:class] = merge_classes(html_options[:class], 'image-label-link')
    link_to(image_label(image_src, name, html_options), options, html_options)
  end
 
  def image_link_to_unless_current(image_src, name, options = {}, html_options = {})
    html_options[:class] = merge_classes(html_options[:class], 'image-label-link')
    link_to_unless_current(image_label(image_src, name, html_options), options, html_options)
  end
  
  def image_link_to_function(image_src, name, function, options = {}, html_options = {})
    html_options[:class] = merge_classes(html_options[:class], 'image-label-link')
    link_to_function(image_label(image_src, name, html_options), function, html_options)
  end
  
  def image_label(image_src, name, options = {})
    locals = {
      :image => image_src,
      :label => (options[:hide_label] || false) ? nil : name,
      :label_align => options.delete(:label_align) || :right,
      :options => options.reverse_merge({ :alt => name, :title => name })
    }
    render :partial => 'layout/image_label', :locals => locals
  end
  
  def icon_link_to(icon_name, name, options = {}, html_options = {})
    html_options[:class] = merge_classes(html_options[:class], 'image-label-link')
    link_to(icon_label(icon_name, name, html_options), options, html_options)
  end
  
  def icon_link_to_unless_current(icon_name, name, options = {}, html_options = {})
    html_options[:class] = merge_classes(html_options[:class], 'image-label-link')
    link_to_unless_current(icon_label(icon_name, name, html_options), options, html_options)
  end
  
  def icon_link_to_function(icon_name, name, function, options = {}, html_options = {})
    html_options[:class] = merge_classes(html_options[:class], 'image-label-link')
    link_to_function(icon_label(icon_name, name, html_options), function, html_options)
  end
  
  def icon_src(icon_name)
    (Dir["#{RAILS_ROOT}/public/images/icons/#{icon_name}.*"] +
      Dir["#{RAILS_ROOT}/public/plugin_assets/*/images/icons/#{icon_name}.*"]).map { |path| path.sub(Regexp.new("#{RAILS_ROOT}/public"), '') }.first
  end
  
  def icon(icon_name, options = {})
    if src = icon_src(icon_name)
      image_tag(src, options)
    end
  end
  
  def icon_label(icon_name, name, options = {})
    image_label(icon_src(icon_name), name, options)
  end
  
  def button_link_to(name, options = {}, html_options = {})
    button_class = html_options.delete(:class)
    content_tag(:input, nil, html_options.merge({ :type => 'button', :value => name, :onclick => "location.href='#{url_for(options)}'" }))
  end
  
  def render_separator(options = {})
    content_tag(:hr)
  end
  
  def render_heading(label, options = {})
    locals = {
      :label => label,
      :actions => actions_for(options[:actions])
    }
    render :partial => 'layout/heading', :locals => locals
  end
  
  def render_field(*args)
    options = args.extract_options!
    label = args.length > 1 ? args.first : nil
    value = args.last
    locals = {
      :value => value.is_a?(Array) ? (options[:count] ? value.length : nil) : value,
      :values => value.is_a?(Array) ? value : nil,
      :label => label,
      :actions => actions_for(options[:actions])
    }
    render :partial => 'layout/show_field', :locals => locals
  end
  
  def render_list(values, options = {})
    list_type = options.delete(:ordered) ? :ol : :ul
    content_tag(list_type, values.map { |value| content_tag :li, value, :class => (value == values.first ? 'first' : nil) }.join, options)
  end
  
  def render_bar_list(values, options = {})
    options[:class] = merge_classes(options[:class], 'bar-list')
    render_list(values, options)
  end

  def render_formatted(text, options = {})
    options[:class] = merge_classes(options[:class], 'formatted')
    content = auto_format(text)
    content = truncate(content, :length => options[:truncate]) if options[:truncate]
    content_tag(:div, content, options)
  end
  
  def render_text_area(text, options = {})
    options[:class] = merge_classes(options[:class], 'show-text-area')
    render_formatted(text, options)
  end
  
  def render_actions(actions, options = {})
    render_bar_list(actions_for(actions), :class => merge_classes(options[:class], 'actions'))
  end
  
  def render_submit(value, options = {})
    content_tag :div, :class => merge_classes(options[:class], 'form-element') do
      content_tag :p, submit_tag(value, options)
    end
  end
  
  def render_submit_with_cancel(options = {})
    submit_name = options[:submit] || t(:submit)
    cancel_name = options[:cancel] || t(:cancel)
    content_tag :div, :class => merge_classes(options[:class], 'form-element') do
      content_tag :p, "#{submit_tag(submit_name, options)} #{link_to_back(cancel_name)}"
    end
  end
    
  def render_user_card(user, options = {})
    locals = {
      :user => user,
      :image_style => options[:image_style] || :thumb
    }
    render :partial => 'users/user_card', :locals => locals
  end
end