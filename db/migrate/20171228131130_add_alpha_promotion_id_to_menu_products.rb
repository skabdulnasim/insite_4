class AddAlphaPromotionIdToMenuProducts < ActiveRecord::Migration
  def change
  	add_column :menu_products, :alpha_promotion_id, :integer
  end
end
