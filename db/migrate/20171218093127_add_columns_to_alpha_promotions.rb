class AddColumnsToAlphaPromotions < ActiveRecord::Migration
  def change
  	add_column :alpha_promotions, :promo_user, :string
  	add_column :alpha_promotions, :count, :integer
  end
end
