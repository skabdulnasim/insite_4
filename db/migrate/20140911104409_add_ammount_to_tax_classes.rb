class AddAmmountToTaxClasses < ActiveRecord::Migration
  def change
    add_column :tax_classes, :ammount, :text
  end
end
