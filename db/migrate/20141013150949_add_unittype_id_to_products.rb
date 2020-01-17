class AddUnittypeIdToProducts < ActiveRecord::Migration
  def change
    add_column :products, :unittype_id, :integer
  end
end
