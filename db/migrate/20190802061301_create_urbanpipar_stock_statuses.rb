class CreateUrbanpiparStockStatuses < ActiveRecord::Migration
  def change
    create_table :urbanpipar_stock_statuses do |t|
      t.integer :menu_product_id
      t.string :selected_channel
      t.string :stock_status

      t.timestamps
    end
  end
end
