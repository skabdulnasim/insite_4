class CreateCustomerProductWishlists < ActiveRecord::Migration
  def change
    create_table :customer_product_wishlists do |t|
      t.integer :cusomer_id
      t.integer :product_id
      t.integer :menu_product_id
      t.integer :menu_card_id
      t.integer :mode

      t.timestamps
    end
  end
end
