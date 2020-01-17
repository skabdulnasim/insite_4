class AddSectionIdToOrderDetails < ActiveRecord::Migration
  def change
    add_column :order_details, :section_id, :integer
    add_column :orders, :section_id, :integer
    add_column :bills, :section_id, :integer
  end
end
