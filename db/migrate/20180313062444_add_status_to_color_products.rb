class AddStatusToColorProducts < ActiveRecord::Migration
  def change
    add_column :color_products, :status, :integer, :default => 0
  end
end
