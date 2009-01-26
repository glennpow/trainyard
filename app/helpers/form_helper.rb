module FormHelper
  # EXAMPLE: option_tags([["one", "One", { :title => "one-title" }], ["two", "Two"]], "two")
  def option_tags(choices, default = nil)
    returning('') do |content|
      choices.each do |choice|
        selected = (choice[1] == default)
        options = choice[2] ? choice[2].inject("") { |result, value| " #{value[0]}='#{value[1]}'" } : ""
        content << "<option value='#{choice[1]}'#{selected ? " selected='selected'" : ''}#{options}>#{choice[0]}</option>"
      end
    end
  end
  
  def labeled_field(field, options = {}, &block)
    label_options = options[:label] || {}
    locals = {
      :input => capture(&block),
      :label => label_tag(field, label_options.delete(:name), label_options),
      :required => options[:required] || false,
      :error => nil
    }
    content = render :partial => 'theme/field', :locals => locals
    block_called_from_erb?(block) ? concat(content) : content
  end
  
  def form_element(value, options = {})
    content_tag :div, value, :class => merge_classes(options[:class], 'form-element')
  end
end