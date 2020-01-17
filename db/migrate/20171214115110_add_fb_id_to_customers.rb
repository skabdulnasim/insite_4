class AddFbIdToCustomers < ActiveRecord::Migration
  def change
    add_column :customers, :fb_id, :string
  end
end
