class Action < ActiveEnumeration::Base
  has_enumerated :view, :translate_key => 'authentication.actions.view'
  has_enumerated :edit, :translate_key => 'authentication.actions.edit'
  has_enumerated :add_article, :translate_key => 'authentication.actions.add_article'
end