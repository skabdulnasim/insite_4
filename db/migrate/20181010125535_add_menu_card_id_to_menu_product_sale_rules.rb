class AddMenuCardIdToMenuProductSaleRules < ActiveRecord::Migration
  def change
    add_column :menu_product_sale_rules, :menu_card_id, :integer
  end
end
