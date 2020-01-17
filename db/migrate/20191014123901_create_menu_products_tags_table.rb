class CreateMenuProductsTagsTable < ActiveRecord::Migration
  def self.up
    create_table :menu_products_tags, :id => false do |t|
        t.references :menu_product
        t.references :tag
    end
    add_index :menu_products_tags, [:menu_product_id, :tag_id]
    add_index :menu_products_tags, :tag_id
  end

  def self.down
    drop_table :menu_products_tags
  end
end
