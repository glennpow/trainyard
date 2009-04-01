module ThemesHelper
  def stylesheet_link_tag_theme(*args)
    if stylesheet_theme = current_theme
      args << 'themes/stylesheet' unless args.any?
      returning('') do |content|
        args.each do |stylesheet_template|
          stylesheet_template << ".css.erb"
          content << content_tag(:style, render(:partial => stylesheet_template, :locals => { :theme => stylesheet_theme }), :class => 'text/css')
        end
      end
    end
  end
  
  def jscolor_init
    javascript('jscolor/jscolor', :plugin => 'trainyard')
  end
  
  def theme_url_params(theme)
    index = -1
    theme.theme_elements.map do |theme_element|
      index += 1
      theme_element_url_params(theme_element, index)
    end.join('+')
  end
  
  def theme_element_url_params(theme_element, index)
    theme_element.attributes.map do |attribute, value|
      "'&theme[theme_elements_attributes][#{index}][#{attribute}]='+escape(document.getElementById('theme_theme_elements_attributes_#{index}_#{attribute}').value)"
    end.join('+')
  end
end