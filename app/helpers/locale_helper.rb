module LocaleHelper
  def session_locale_select
    if (locales = Locale.find_by_localized_name.map { |locale| [ locale.localized_name, locale.id ] }).length > 1
      locals = {
        :default_locale => current_locale,
        :locales => locales
      }
      render :partial => 'layout/session_locale_select', :locals => locals
    end
  end
end