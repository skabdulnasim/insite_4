class AddImageColumnToAlphaPromotion < ActiveRecord::Migration
  def change
    add_attachment :alpha_promotions, :image
  end
end