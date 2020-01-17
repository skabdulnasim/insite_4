class AddStoreCreatabilityToUnits < ActiveRecord::Migration
  def change
    add_column :units, :store_creatability, :integer
  end
end
