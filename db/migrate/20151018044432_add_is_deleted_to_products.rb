class AddIsDeletedToProducts < ActiveRecord::Migration
  def change
    add_column :products, :is_trashed, :boolean, default: false    
  end
end
