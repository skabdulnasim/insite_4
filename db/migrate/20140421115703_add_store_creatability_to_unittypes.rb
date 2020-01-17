class AddStoreCreatabilityToUnittypes < ActiveRecord::Migration
  def change
    add_column :unittypes, :store_creatability, :integer
  end
end
