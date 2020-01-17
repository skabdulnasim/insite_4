class AddFbIdToCustomerProfiles < ActiveRecord::Migration
  def change
    add_column :customer_profiles, :picture_url, :text
    add_column :customer_profiles, :profile_url, :text
  end
end
