class AddSkuToReturnItems < ActiveRecord::Migration
  def change
    add_column :return_items, :sku, :string
  end
end
