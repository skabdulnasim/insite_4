class CreateOrderProformas < ActiveRecord::Migration
  def change
    create_table :order_proformas do |t|
      t.references :order
      t.references :proforma

      t.timestamps
    end
    add_index :order_proformas, :order_id
    add_index :order_proformas, :proforma_id
  end
end