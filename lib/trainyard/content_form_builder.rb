# TODO
#require_dependency 'locale'

module Trainyard
  class ContentFormBuilder < ActionView::Helpers::FormBuilder
    def initialize(object_name, object, template, options, proc)
      object ||= template.instance_variable_get("@#{object_name}") unless object_name =~ /[\[\]]/
      super
    end
  
    helpers = field_helpers +
      %w(date_select datetime_select time_select collection_select) +
      %w(collection_select select country_select time_zone_select) -
      %w(label fields_for hidden_field)

    helpers.each do |name|
      define_method name do |field, *args|
        options = args.detect {|argument| argument.is_a?(Hash)} || {}
        layout = options.delete(:layout)
        if layout == false
          super
        else
          labeled_field(field, options) do
            super
          end
        end
      end
    end

    def labeled_field(field, options = {}, &block)
      is_erb = @template.send(:block_called_from_erb?, block)
      label_options = options[:label] || {}
      locals = {
        :input_class => options[:input_class] || '',
        :input => is_erb ? @template.capture(&block) : yield,
        :label_class => label_options.delete(:class) || '',
        :label => label(field, label_options.delete(:name), label_options),
        :hint_class => options[:hint_class],
        :hint => options[:hint],
        :required => options[:required] || false,
        :error => error_message(field, options[:error])
      }
      content = @template.render :partial => 'theme/field', :locals => locals
      is_erb ? @template.concat(content) : content
    end
  
    def text_area(field, options = {})
      labeled_field(field, options.merge({ :input_class => 'text-area' })) do
        super(field, options.merge({ :rows => 8 }))
      end
    end
  
    def field_error(field, options = {})
      locals = {
        :error => error_message(field, options)
      }
      @template.capture do
        @template.render :partial => 'theme/field_error', :locals => locals
      end
    end

    def error_message(field, options)
      if has_errors_on?(field)
        errors = object.errors.on(field)
        errors.is_a?(Array) ? errors.to_sentence : errors
      else
        nil
      end
    end

    def has_errors_on?(field)
      !(object.nil? || object.errors.on(field).blank?)
    end

    def form_for(record_or_name_or_array, *args)
      options = args.detect { |argument| argument.is_a?(Hash) }
      if options.nil?
        options = {}
        args << options
      end

      case record_or_name_or_array
      when String, Symbol
        name = record_or_name_or_array.to_s
        object = (args.first unless args.first.is_a?(Hash)) || self.object.send(record_or_name_or_array)
        klass = self.object.class.reflect_on_association(name.to_sym).klass
        if object.is_a?(Array)
          names = name
          name = names.singularize
          div_class = "#{names}-form"
        else
          names = name.pluralize
          div_class = "#{name}-form"
        end
      else
        object = record_or_name_or_array
        if object.is_a?(Array)
          name = ActionController::RecordIdentifier::singular_class_name(object.last)
          names = name.pluralize
          div_class = "#{names}-form"
        else
          name = ActionController::RecordIdentifier::singular_class_name(object)
          names = name.pluralize
          div_class = "#{name}-form"
        end
        klass = object.class
      end
    
      header = options.delete(:header)
    
      render_options = options.delete(:render) || {}
      render_options[:partial] ||= "#{names}/edit"
      render_options[:locals] ||= {}
      render_options[:locals][name.to_sym] = object
      render_options[:layout] = 'theme/item' if object.is_a?(Array)

      @template.content_tag(:div, :class => "form-section #{div_class}") do
        returning('') do |content|
          if header
            content << @template.render_heading(header, :actions => [ {
              :if => object.is_a?(Array),
              :allow => create_link(klass, render_options.deep_dup, :name => name, :names => names, :label => @template.icon_label(:add, @template.t(:add)))
              } ])
          end
          if object.is_a?(Array)
            options[:index] = ''
            content << @template.content_tag(:div, :id => "#{names}") do
              returning('') do |div_content|
                object.each do |element|
                  fields_for(names, element, *args) do |f|
                    render_options[:locals][name.to_sym] = element
                    render_options[:locals][:f] = f
                    div_content << @template.render(render_options.deep_dup)
                  end
                end
              end
            end
            content << create_link(klass, render_options.deep_dup, :name => name, :names => names) unless header
          else
            fields_for(name, object, *args) do |f|
              render_options[:locals][:f] = f
              content << @template.render(render_options.deep_dup)
            end
          end
        end
      end
    end
  
    def fields_for(record_or_name_or_array, *args, &block)
      # XXX - this is to solve mass-assign updating of collections...
      #if options.has_key?(:index)
      #  index = "[#{options[:index]}]"
      #elsif defined?(@auto_index)
      #  self.object_name = @object_name.to_s.sub(/\[\]$/,"")
      #  index = "[#{@auto_index}]"
      #else
        index = ""
      #end

      case record_or_name_or_array
      when String, Symbol
        object = (args.first unless args.first.is_a?(Hash)) || self.object.send(record_or_name_or_array)
        name = "#{object_name}#{index}[#{record_or_name_or_array}]"
        args.unshift(object) unless args.include?(object)
      when Array
        object = record_or_name_or_array.last
        name = "#{object_name}#{index}[#{ActionController::RecordIdentifier.singular_class_name(object)}]"
        args.unshift(object)
      else
        object = record_or_name_or_array
        name = "#{object_name}#{index}[#{ActionController::RecordIdentifier.singular_class_name(object)}]"
        args.unshift(object)
      end
      @template.fields_for(name, *args, &block)
    end
   
    def create_link(record_class, render_options, options = {})
      element = record_class.new
      name = options[:name] || ActionController::RecordIdentifier.singular_class_name(record)
      names = options[:names] || name.pluralize
      update = options[:update] || names
      label = options[:label] || I18n.t(:add_object, :object => name.capitalize)
      args = options[:args] || []
    
      content = ''
      fields_for("#{names}[]", element, *args) do |f|
        render_options[:locals][name.to_sym] = element
        render_options[:locals][:f] = f
        content << @template.render(render_options.deep_dup)
      end
    
      @template.link_to_function label do |page|
        page.insert_html :bottom, update.to_sym, content
      end
    end
 
    def yes_no_select(name, options = {}, html_options = {})
      select(name, [ [ I18n.t(:yes), true ], [ I18n.t(:no), false ] ], options, html_options)
    end
     
    def locale_select(name, options = {}, html_options = {})
      options[:selected] ||= @template.current_locale.id
      if options.delete(:localized)
        choices = Locale.find_by_localized_name.map { |locale| [ locale.localized_name, locale.id ] }
      else
        choices = Locale.find_by_name.map { |locale| [ locale.name, locale.id ] }
      end
      select(name, choices, options, html_options)
    end
     
    def group_select(name, options = {}, html_options = {})
      order = options.delete(:order) || 'name ASC'
      if memberships_options = options.delete(:memberships)
        user = memberships_options[:user]
        roles = (memberships_options[:roles] || [ Role.user ]).map(&:id)
      end
      groups = if user
        Group.all(:include => :memberships, :conditions => { "#{Membership.table_name}.user_id" => user, "#{Membership.table_name}.role_id" => roles }, :order => order)
      else
        groups = Group.all(:order => order)
      end
      collection_select(name, groups, :id, :name, options, html_options)
    end
  
    def rating_select(name, options = {}, html_options = {})
      max_rating = (options[:max_rating] || 5).to_i
      locals = {
        :name => "#{@object_name}[#{name}]",
        :rating => @object.send(name) || 0,
        :max_rating => max_rating,
        :type => options[:type] || "/ #{max_rating}"
      }
      labeled_field(name, options) do
        @template.capture do
          @template.render :partial => 'theme/rating_select', :locals => locals
        end
      end
    end
  
    def color_field(name, options = {})
      text_field(name, options.merge({ :class => 'color', :value => @object.send(name) }))
    end

    def submit(value, options = {})
      class_name = options[:class_name] || 'form-submit'
      @template.content_tag :div, :class => "form-element #{class_name}" do
        @template.content_tag :p, super(value, options)
      end
    end
  end
end