class CreateExternalOrders < ActiveRecord::Migration
  def change
    create_table :external_orders do |t|
      t.string :order_json

      t.timestamps
    end
  end
end
