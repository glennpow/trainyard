module LocaleHelper
  def session_locale_select
    locals = {
      :default_locale => current_locale,
      :locales => Locale.find_by_localized_name.map { |locale| [ locale.localized_name, locale.id ] }
    }
    capture do
      render :partial => 'theme/session_locale_select', :locals => locals
    end
  end
end