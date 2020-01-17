class CreateAllergyProducts < ActiveRecord::Migration
  def change
    create_table :allergy_products do |t|
      t.integer :product_id
      t.integer :allergy_id

      t.timestamps
    end
  end
end
