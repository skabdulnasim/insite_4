class RemoveRestRegIdFromTaxClasses < ActiveRecord::Migration
  def up
    remove_column :tax_classes, :rest_reg_no
  end
end
