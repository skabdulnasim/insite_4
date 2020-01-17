class CreateStockTransferTemplates < ActiveRecord::Migration
  def change
    create_table :stock_transfer_templates do |t|
      t.string :template_name
      t.integer :store_id
      t.integer :user_id
      t.string :template_type

      t.timestamps
    end
    add_index("stock_transfer_templates", "store_id")
    add_index("stock_transfer_templates", "user_id")
  end
end
