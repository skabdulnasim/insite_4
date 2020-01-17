class AddVariationsToProductAttributes < ActiveRecord::Migration
  def change
    add_column :product_attributes, :variations, :text

    add_column :product_attributes, :term_attribute_id, :integer
  end
end
