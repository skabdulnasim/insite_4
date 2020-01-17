class AddBillSplitIdToPayments < ActiveRecord::Migration
  def change
    add_column :payments, :bill_split_id, :integer
  end
end
