class ItemPreference < ActiveRecord::Base
  attr_accessible :preference

  #Model Relations
  has_many :category_item_preferences
  has_many :menu_categories, through: :category_item_preferences
end
