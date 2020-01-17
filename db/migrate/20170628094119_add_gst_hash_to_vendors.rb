class AddGstHashToVendors < ActiveRecord::Migration
  def change
    add_column :vendors, :gst_hash, :string
  end
end
