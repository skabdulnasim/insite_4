class AddBatchNoToLots < ActiveRecord::Migration
  def change
    add_column :lots, :batch_no, :string
  end
end
