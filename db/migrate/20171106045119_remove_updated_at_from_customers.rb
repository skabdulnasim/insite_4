class RemoveUpdatedAtFromCustomers < ActiveRecord::Migration
  def change
    remove_column :customers, :updated_at
  end
end
