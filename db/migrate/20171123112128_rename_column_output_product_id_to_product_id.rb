class RenameColumnOutputProductIdToProductId < ActiveRecord::Migration
  def up
  	rename_column :simo_output_product_templates, :output_product_id, :product_id
  end

  def down
  end
end
