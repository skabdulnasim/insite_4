class AddProfilePictureToCustomerProfiles < ActiveRecord::Migration
  def up
	add_attachment :customer_profiles, :profile_picture
  end

  def down
	remove_attachment :customer_profiles, :profile_picture
  end
end
