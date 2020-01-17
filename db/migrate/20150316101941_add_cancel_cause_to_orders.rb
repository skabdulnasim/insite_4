class AddCancelCauseToOrders < ActiveRecord::Migration
  def change
    add_column :orders, :cancel_cause, :text
  end
end
