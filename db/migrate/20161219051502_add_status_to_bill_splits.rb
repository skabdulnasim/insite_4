class AddStatusToBillSplits < ActiveRecord::Migration
  def change
    add_column :bill_splits, :status, :string
  end
end
