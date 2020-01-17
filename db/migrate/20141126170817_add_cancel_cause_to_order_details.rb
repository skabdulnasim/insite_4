class AddCancelCauseToOrderDetails < ActiveRecord::Migration
  def change
    add_column :order_details, :cancel_cause, :text
  end
end
