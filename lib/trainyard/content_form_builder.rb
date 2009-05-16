module Trainyard
  class ContentFormBuilder < ActionView::Helpers::FormBuilder
    
    def initialize(object_name, object, template, options, proc)
      object ||= template.instance_variable_get("@#{object_name}") unless object_name =~ /\[.*\]/
      super(object_name, object, template, options, proc)
    end
    
    
    public

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
      label_options = (options[:label] || {}).deep_dup
      case label_options
      when Hash
        label_class = label_options.delete(:class) || ''
        label = label(field, label_options.delete(:name), label_options)
      else
        label_class = ''
        label = label(field, label_options)
      end
      
      locals = {
        :input_class => options[:input_class] || '',
        :input => is_erb ? @template.capture(&block) : yield,
        :label_class => label_class,
        :label => label,
        :hint_class => options[:hint_class],
        :hint => options[:hint],
        :required => options[:required] || false,
        :error => error_message(field, options[:error])
      }
      content = @template.render :partial => 'layout/field', :locals => locals
      is_erb ? @template.concat(content) : content
    end
  
    def text_area(field, options = {})
      @template.capture do
        @template.concat(labeled_field(field, options.merge({ :input_class => 'text-area' })) do
          super(field, options.merge({ :rows => 8 }))
        end)
        if options[:preview]
          label = (options[:label] || {})[:name] || field.to_s.humanize
          text_area_id = "#{object_name}_#{field}".gsub(/[\[\]]/, '_').gsub(/__+/, '_')
          @template.concat(@template.render(:partial => 'layout/text_area_preview_area', :locals => { :text_area_id => text_area_id, :label => label }))
        end
        @template.output_buffer
      end
    end
    
    def rich_text_area(field, options = {})
      if (@template.respond_to?(:fckeditor_textarea))
        options.reverse_merge!(:toolbarSet => 'Simple', :width => '100%', :height => '300px')

        @template.javascript('fckeditor/fckeditor')
        @template.fckeditor_textarea(object_name.to_sym, field, options)
      else
        text_area(field, options)
      end
    end
  
    def field_error(field, options = {})
      locals = {
        :error => error_message(field, options)
      }
      @template.capture do
        @template.render :partial => 'layout/field_error', :locals => locals
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
      options = args.extract_options!
      args << options

      case record_or_name_or_array
      when String, Symbol
        name = record_or_name_or_array.to_s

        object = (args.first unless args.first.is_a?(Hash)) || (self.object ? self.object.send(record_or_name_or_array) : nil)
        if object
          klass = object.class
          is_array = object.is_a?(Array)
        else
          # reflection = @object_class.reflect_on_association(name.to_sym)
          reflection = self.object.class.reflect_on_association(name.to_sym)
          klass = reflection.klass
          if is_array = (reflection.macro == :has_many)
            object = []
          elsif self.object
            object = self.object.send("build_#{record_or_name_or_array}")
          end
        end
        if is_array
          names = name
          name = names.singularize
          div_class = "#{names}-form"
        else
          names = name.pluralize
          div_class = "#{name}-form"
        end
      else
        object = record_or_name_or_array
        klass = object.class
        if is_array = object.is_a?(Array)
          name = ActionController::RecordIdentifier::singular_class_name(object.last)
          names = name.pluralize
          div_class = "#{names}-form"
        else
          name = ActionController::RecordIdentifier::singular_class_name(object)
          names = name.pluralize
          div_class = "#{name}-form"
        end
      end
      
      heading = options.delete(:heading)
    
      options[:object_class] = klass
      options[:object_array] = is_array
      has_create_link = is_array && options[:create_link]
      
      render_options = options.delete(:render) || {}
      render_options[:partial] ||= "#{names}/edit"
      render_options[:locals] ||= {}
      render_options[:locals][name.to_sym] = object
      render_options[:layout] ||= 'layout/item' if is_array && render_options[:layout] != false
    
      @template.concat("<div class='form-section #{div_class}'>")
      if heading
        @template.concat(@template.render_heading(heading, :actions => [ has_create_link ?
          create_link(klass, render_options.deep_dup, :name => name, :names => names, :label => @template.icon_label(:add, @template.t(:add))) : nil ]))
      end
      if is_array
        @template.concat("<div id='#{names}'>")
        fields_for(record_or_name_or_array, *args) do |f|
          render_options[:locals][:f] = f
          render_options[:locals][name.to_sym] = f.object
          @template.concat(@template.render(render_options.deep_dup))
        end
        @template.concat("</div>")
        @template.concat(create_link(klass, render_options.deep_dup, :name => name, :names => names)) unless heading || !has_create_link
      else
        fields_for(record_or_name_or_array, *args) do |f|
          render_options[:locals][:f] = f
          @template.concat(@template.render(render_options.deep_dup))
        end
      end
      @template.concat("</div>")
    end
   
    def create_link(record_class, render_options, options = {})
      name = options[:name] || ActionController::RecordIdentifier.singular_class_name(record_class)
      names = options[:names] || name.pluralize
      update = options[:update] || names
      label = options[:label] || I18n.t(:add_object, :object => name.capitalize)
      args = options[:args] || []
    
      object = self.object.send(names).build
      content = @template.capture do
        fields_for(names, object, :child_index => 'NEW_RECORD', *args) do |f|
          render_options[:locals][:f] = f
          render_options[:locals][name.to_sym] = f.object
          @template.render(render_options.deep_dup)
        end
      end
      self.object.send(names).delete(object)
    
      @template.link_to_function label do |page|
        page << "$('#{update}').insert({ bottom: '#{escape_javascript(content)}'.replace(/NEW_RECORD/g, new Date().getTime()) });"
      end
    end
    
    def contact_form(options = {})
      form_for(:address, :heading => @template.t(:address, :scope => [ :contacts ])) unless options[:address] == false
      form_for(:emails, :heading => @template.tp(:email, :scope => [ :contacts ]), :create_link => true) unless options[:emails] == false
      form_for(:phones, :heading => @template.tp(:phone, :scope => [ :contacts ]), :create_link => true) unless options[:phones] == false
      form_for(:urls, :heading => @template.tp(:url, :scope => [ :contacts ]), :create_link => true) unless options[:urls] == false
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

    def localization_select(options = {})
      labeled_field(I18n.t(:language, :scope => [ :content ]).pluralize, options.merge(:hint => I18n.t(:localization_select_hint, :scope => [ :content ]))) do
        @template.localization_select(self, options)
      end
    end
    
    def localized_text_field(name, options = {})
      @template.localized_text_field(self, name, options.merge(:label => Proc.new { |locale, locale_name| { :name => "#{name.to_s.humanize} (#{locale_name})" } }))
    end
    
    def localized_text_area(name, options = {})
      @template.localized_text_area(self, name, options.merge(:label => Proc.new { |locale, locale_name| { :name => "#{name.to_s.humanize} (#{locale_name})" } }))
    end
     
    def group_select(name, options = {}, html_options = {})
      order = options.delete(:order) || 'name ASC'
      if memberships_options = options.delete(:memberships)
        user = memberships_options[:user]
        roles = memberships_options[:roles] || [ Role[:user] ]
      end
      groups = if user
        Group.all(:include => :memberships, :conditions => { "#{Membership.table_name}.user_id" => user, "#{Membership.table_name}.role" => roles }, :order => order)
      else
        groups = Group.all(:order => order)
      end
      collection_select(name, groups, :id, :name, options, html_options) if groups.any?
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
          @template.render :partial => 'layout/rating_select', :locals => locals
        end
      end
    end
  
    def color_field(name, options = {})
      text_field(name, options.merge({ :class => 'color', :value => @object.send(name) }))
    end

    def submit_with_wrapper(value, options = {})
      class_name = options[:class_name] || 'form-submit'
      @template.content_tag :div, :class => "form-element #{class_name}" do
        @template.content_tag :p, submit_without_wrapper(value, options)
      end
    end
    alias_method_chain :submit, :wrapper

    def submit_with_cancel(options = {})
      class_name = options[:class_name] || 'form-submit'
      submit_name = options[:submit] || I18n.t(:submit)
      cancel_name = options[:cancel] || I18n.t(:cancel)
      @template.capture do
        if defined?(Ambethia::ReCaptcha)
          if self.object.respond_to?(:should_verify_human) && self.object.try(:should_verify_human)
            @template.concat @template.content_tag(:div, @template.recaptcha_tags, :class => 'form-recaptcha')
          end
        end
        @template.concat(@template.content_tag(:div, :class => "form-element #{class_name}") do
          @template.content_tag :p, "#{self.submit_without_wrapper(submit_name, options)} #{@template.link_to_back(cancel_name)}"
        end)
      end
    end
  end
end