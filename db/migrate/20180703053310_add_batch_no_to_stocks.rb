class AddBatchNoToStocks < ActiveRecord::Migration
  def change
    add_column :stocks, :batch_no, :string
  end
end
