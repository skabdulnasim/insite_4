class AddPanNoToCustomerProfiles < ActiveRecord::Migration
  def change
    add_column :customer_profiles, :pan_no, :string
    add_column :customer_profiles, :alternate_name, :string
    add_column :customer_profiles, :alternate_mobile, :string
  end
end
