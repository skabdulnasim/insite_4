class AddAdvancePaymentToBills < ActiveRecord::Migration
  def change
    add_column :bills, :advance_payment, :float
  end
end
