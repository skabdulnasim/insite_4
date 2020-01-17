class PromotionUnitMapping < ActiveRecord::Migration
  def up
  	alphapromotions = AlphaPromotion.all
  	units = Unit.all
  	alphapromotions.map { |a| units.map { |u| u.alpha_promotions <<  a } }		
  end

  def down
  end
end
