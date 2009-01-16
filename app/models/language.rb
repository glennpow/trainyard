class Language < ActiveRecord::Base
  validates_presence_of :code

  def name(locale = nil)
    I18n.t(self.code, :scope => [ :languages ], :locale => locale)
  end
  
  def self.by_name
    self.all.sort(&:name)
  end
end
