class AddProductReligionIdToProducts < ActiveRecord::Migration
  def change
    add_column :products, :product_religion_id, :integer
    add_column :products, :callorie, :string
  end
end
