class CategoryItemPreference < ActiveRecord::Base
  
  attr_accessible :menu_category_id, :item_preference_id

  #Model Relations
  belongs_to :menu_category
  belongs_to :item_preference

  def self.save_category_item_preference(item_preference_id, menu_category_ids)
    prev = self.where('item_preference_id =?', item_preference_id)
    prev.destroy_all if prev.present?
  	menu_category_ids.each do |menu_category_id|
  	  CategoryItemPreference.create(:item_preference_id => item_preference_id, :menu_category_id => menu_category_id)
		end
  end
end
