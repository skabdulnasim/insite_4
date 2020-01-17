class AddSplitBillIdToSettlements < ActiveRecord::Migration
  def change
  	add_column :settlements, :split_bill_id, :integer
  end
end
