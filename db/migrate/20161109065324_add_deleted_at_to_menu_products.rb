class AddDeletedAtToMenuProducts < ActiveRecord::Migration
  def change
    add_column :menu_categories, :deleted_at, :datetime
    add_column :menu_products, :deleted_at, :datetime
  end
end
