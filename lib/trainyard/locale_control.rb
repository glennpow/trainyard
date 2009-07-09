module Trainyard
  module LocaleControl
    def set_locale
      available_locales = Locale.available_codes
      LocalizedRecord.available_locales = Language.available_languages if defined?(LocalizedRecord)
      locale = params[:locale] || session[:locale] || request.preferred_language_from(available_locales)
      locale = available_locales.include?(locale) ? locale : Configuration.default_locale
      session[:locale] = locale
      I18n.locale = Locale.parse_language_code(locale)
      logger.debug "Application locale: #{locale}, I18n locale: #{I18n.locale}"
    end

    def tp(key, options = {})
      I18n.translate(key, options).pluralize
    end

    def tt(key, options = {})
      textilized = RedCloth.new(I18n.translate(key, options), [ :hard_breaks ])
      textilized.hard_breaks = true if textilized.respond_to?("hard_breaks=")
      textilized.to_html
    end
  
    def current_locale
      Locale.find_by_code(session[:locale])
    end
  
    def all_by_locale(records, options = {})
      locale = current_locale
      default_locale = Locale.find_by_code(Configuration.default_locale)
      attributes = options.except(:include_default_country, :include_default_language)
      matching_both = []
      matching_country = []
      matching_language = []
      records.each do |record|
        if record.respond_to?(:locale)
          if record.locale.nil? || (locale.nil? && default_locale.nil?)
            matching_both << record
          elsif attributes.any? && attributes.detect { |key, value| !record.respond_to?(key) || record.send(key) != value }
          else
            matches_country = (locale && record.locale.country == locale.country) || (options[:include_default_country] && default_locale && record.locale.country == default_locale.country)
            matching_country << record if matches_country
            matches_language = (locale && record.locale.language == locale.language) || (options[:include_default_language] && default_locale && record.locale.language == default_locale.language)
            matching_language << record if matches_language
          end
        end
      end
      return (matching_both + matching_country + matching_language).uniq
    end
    
    def first_by_locale(records, options = {})
      all_by_locale(records, options).first
    end
  
    def for_each_by_locale(records, options = {}, &block)
      all_by_locale(records, options).each { |record| block.call(record) }
    end
  
    def for_first_by_locale(records, options = {}, &block)
      record = first_by_locale(records, options)
      block.call(record) if record
    end

    def set_time_zone
      Time.zone = current_user.time_zone if logged_in?
    end
  
    def self.included(base)
      base.send :helper_method, :tp, :tt, :current_locale, :all_by_locale, :first_by_locale,
        :for_each_by_locale, :for_first_by_locale if base.respond_to? :helper_method
      if base.respond_to? :before_filter
        base.send :before_filter, :set_locale
        base.send :before_filter, :set_time_zone
      end
    end
  end
end

ActionController::Base.send(:include, Trainyard::LocaleControl) if defined?(ActionController::Base)