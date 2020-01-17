class ChangeValidFromAndValidTillColumnTypeInAlphaPromotions < ActiveRecord::Migration
  def change
  	change_column :alpha_promotions, :valid_from, :datetime
  	change_column :alpha_promotions, :valid_till, :datetime
  end
end