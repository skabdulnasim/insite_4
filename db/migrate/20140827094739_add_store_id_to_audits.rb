class AddStoreIdToAudits < ActiveRecord::Migration
  def change
    add_column :audits, :store_id, :integer
  end
end
