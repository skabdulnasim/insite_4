class AddPasswordDigestToDeliveryBoys < ActiveRecord::Migration
  def change
    add_column :delivery_boys, :password_digest, :string
  end
end
