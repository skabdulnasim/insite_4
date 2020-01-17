class CreateStockTransferTemplateProducts < ActiveRecord::Migration
  def change
    create_table :stock_transfer_template_products do |t|
      t.integer :stock_transfer_template_id
      t.integer :product_id
      t.float :quantity

      t.timestamps
    end
    add_index("stock_transfer_template_products", "product_id")
    
  end
end
