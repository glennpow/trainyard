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
    is_erb = block_called_from_erb?(block)
    label_options = options[:label] || {}
    locals = {
      :input_class => options[:input_class] || '',
      :input => is_erb ? @template.capture(&block) : yield,
      :label_class => label_options.delete(:class) || '',
      :label => label_tag(field, label_options.delete(:name), label_options),
      :hint_class => options[:hint_class],
      :hint => options[:hint],
      :required => options[:required] || false,
      :error => nil
    }
    content = render :partial => 'layout/field', :locals => locals
    is_erb ? concat(content) : content
  end
  
  def form_element(value, options = {})
    content_tag :div, value, :class => merge_classes(options[:class], 'form-element')
  end
end