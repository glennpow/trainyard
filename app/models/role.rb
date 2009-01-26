class Role < ActiveEnumeration::Base
  has_enumerated :administrator, :translate_key => 'authentication.roles.administrator'
  has_enumerated :editor, :translate_key => 'authentication.roles.editor'
  has_enumerated :user, :translate_key => 'authentication.roles.user'
end