class AddRestRegNoToTaxClasses < ActiveRecord::Migration
  def change
    add_column :tax_classes, :rest_reg_no, :integer
  end
end
