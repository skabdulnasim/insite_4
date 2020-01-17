class CreateCustomerPromos < ActiveRecord::Migration
  def change
    create_table :customer_promos do |t|
      t.integer :unit_id
      t.integer :customer_id
      t.integer :promo_id
      t.string :promo_code
      t.integer :count

      t.timestamps
    end
  end
end
