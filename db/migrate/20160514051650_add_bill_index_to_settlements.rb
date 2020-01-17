class AddBillIndexToSettlements < ActiveRecord::Migration
  def change
    add_index :settlements, :bill_id, unique: true, :name => 'index_settlements_on_unique_bill_id'
  end
end
