class AddPromoScopeToAlphaPromotions < ActiveRecord::Migration
  def change
    add_column :alpha_promotions, :scope, :string
  end
end
