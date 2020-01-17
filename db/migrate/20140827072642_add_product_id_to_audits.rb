class AddProductIdToAudits < ActiveRecord::Migration
  def change
    add_column :audits, :product_id, :integer
  end
end
