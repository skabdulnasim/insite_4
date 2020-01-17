class AddDeliverablesToBill < ActiveRecord::Migration
  def change
    add_column :bills, :deliverable_id, :integer
    add_column :bills, :deliverable_type, :string
    remove_column :bills, :table_id
  end
end
