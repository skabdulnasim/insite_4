class AddBillerTypeToBills < ActiveRecord::Migration
  def change
    add_column :bills, :biller_type, :string, :default => "User"
    add_column :bills, :biller_id, :integer
    Bill.update_all("biller_id=user_id")
  end
end
