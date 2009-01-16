module Trainyard
  module LocaleSystem
    def set_locale
      available_locales = Locale.available_codes
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
  
    def detect_by_locale(records, options = {})
      locale = current_locale
      default_locale = Locale.find_by_code(Configuration.default_locale)
      country_records = records.select do |record|
        if record.respond_to?(:locale) && (record.locale.nil? || locale.nil? || record.locale.country == locale.country)
          if options.any?
            options.detect do |key, value|
              !record.respond_to?(key) || record.send(key) != value
            end.nil?
          else
            true
          end
        else
          false
        end
      end
      return (locale.nil? ? nil : country_records.detect { |record| record.locale && record.locale.language == locale.language }) ||
        country_records.detect { |record| record.locale && record.locale.language == default_locale.language } ||
        country_records.first
    end
  
    def for_locale(records, options = {}, &block)
      record = detect_by_locale(records, options)
      block.call(record) if record
    end

    def set_time_zone
      Time.zone = current_user.time_zone if logged_in?
    end
  
    def self.included(base)
      base.send :helper_method, :tp, :tt, :current_locale, :detect_by_locale, :for_locale if base.respond_to? :helper_method
      if base.respond_to? :before_filter
        base.send :before_filter, :set_locale
        base.send :before_filter, :set_time_zone
      end
    end
  end
end

ActionController::Base.send(:include, Trainyard::LocaleSystem) if defined?(ActionController::Base)