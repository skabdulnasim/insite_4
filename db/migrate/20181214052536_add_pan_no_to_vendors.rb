class AddPanNoToVendors < ActiveRecord::Migration
  def change
    add_column :vendors, :pan_no, :string
  end
end
