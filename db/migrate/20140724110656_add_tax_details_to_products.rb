class AddTaxDetailsToProducts < ActiveRecord::Migration
  def change
    add_column :products, :tax_class_id, :integer
    add_column :products, :tax_ammount, :float
  end
end
