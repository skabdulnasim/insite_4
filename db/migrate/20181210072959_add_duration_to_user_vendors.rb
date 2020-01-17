class AddDurationToUserVendors < ActiveRecord::Migration
  def change
    add_column :user_vendors, :duration, :integer
  end
end
