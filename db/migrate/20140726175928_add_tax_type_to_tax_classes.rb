class AddTaxTypeToTaxClasses < ActiveRecord::Migration
  def change
    add_column :tax_classes, :tax_type, :string
  end
end
