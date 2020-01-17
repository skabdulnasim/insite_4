class AddOperationTypeToTaxClasses < ActiveRecord::Migration
  def change
    add_column :tax_classes, :operation_type, :string
  end
end
