class AddSortIdToMenuProducts < ActiveRecord::Migration
  def change
    add_column :menu_products, :sort_id, :integer
  end
end
