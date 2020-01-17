class DropStockRequisition < ActiveRecord::Migration
  def up
    drop_table :stock_requisitions
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
