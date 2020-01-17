class AddRemarksToBillSplits < ActiveRecord::Migration
  def change
    add_column :bill_splits, :remarks, :string
  end
end
