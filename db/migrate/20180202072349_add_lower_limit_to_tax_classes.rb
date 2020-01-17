class AddLowerLimitToTaxClasses < ActiveRecord::Migration
  def change
    add_column :tax_classes, :upper_limit, :float
    add_column :tax_classes, :lower_limit, :float
  end
end
