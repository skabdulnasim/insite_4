class AddStateToTable < ActiveRecord::Migration
  def change
    add_column :tables, :state, :integer
    add_column :tables, :groups, :string
    add_column :tables, :last_bill_id, :integer
    remove_column :tables, :type
    add_column :tables, :table_type, :integer
    rename_column :tables, :shape, :table_shape
    rename_column :tables, :unit_id, :outlet_id
  end
end
