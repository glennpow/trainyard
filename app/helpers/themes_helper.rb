module ThemesHelper
  def stylesheet_link_tag_theme(*args)
    if @theme = current_theme
      @theme.attributes=(params[:theme])
      args << 'themes/stylesheet' unless args.any?
      returning('') do |content|
        args.each do |stylesheet_template|
          stylesheet_template << ".css.erb"
          content << content_tag(:style, render(:partial => stylesheet_template, :locals => { :theme => @theme }), :class => 'text/css')
        end
      end
    end
  end
  
  def jscolor_init
    javascript('jscolor/jscolor', :plugin => 'trainyard')
  end
end