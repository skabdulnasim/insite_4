class AddBillIdToreservations < ActiveRecord::Migration
  def change
    add_column :reservations, :bill_id, :integer
    add_column :reservations, :status, :text
  end
end
