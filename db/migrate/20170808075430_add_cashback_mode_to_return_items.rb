class AddCashbackModeToReturnItems < ActiveRecord::Migration
  def change
    add_column :return_items, :cashback_mode, :string
  end
end
