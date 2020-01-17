class CreateAlphaPromotions < ActiveRecord::Migration
  def change
    create_table :alpha_promotions do |t|
      t.string :promo_code
      t.string :promo_type
      t.float :promo_value
      t.string :status
      t.text :description
      t.date :valid_from
      t.date :valid_till

      t.timestamps
    end
  end
end
