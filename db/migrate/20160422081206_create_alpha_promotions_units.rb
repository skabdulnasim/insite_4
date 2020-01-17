class CreateAlphaPromotionsUnits < ActiveRecord::Migration
  def change
    create_table :alpha_promotions_units, :id => false do |t|
      t.references :alpha_promotion
      t.references :unit
    end
    add_index :alpha_promotions_units, :alpha_promotion_id
    add_index :alpha_promotions_units, :unit_id
  end
end