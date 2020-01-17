class AddAddressPhoneNoToVendors < ActiveRecord::Migration
  def change
    add_column :vendors, :address_phone_no, :string
  end
end
