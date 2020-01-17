class ChangeTaxClassesTaxGroupsToTaxClassesGroups < ActiveRecord::Migration
  def change
  	rename_table :tax_classes_tax_groups, :tax_classes_groups
  end
end
