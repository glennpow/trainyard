class ThemeablesTheme < ActiveRecord::Base
  belongs_to :themeable, :polymorphic => true
  belongs_to :theme
  
  validates_presence_of :themeable, :theme
end