class AddTaxGroupIdToVendorProducts < ActiveRecord::Migration
  def change
    add_column :vendor_products, :tax_group_id, :integer
  end
end
