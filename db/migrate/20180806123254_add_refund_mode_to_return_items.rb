class AddRefundModeToReturnItems < ActiveRecord::Migration
  def change
    add_column :return_items, :refund_mode, :string
    add_column :return_items, :refund_status, :boolean
  end
end
