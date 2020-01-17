class AddBillerIdToBillSplits < ActiveRecord::Migration
  def change
    add_column :bill_splits, :biller_id, :integer
  end
end
