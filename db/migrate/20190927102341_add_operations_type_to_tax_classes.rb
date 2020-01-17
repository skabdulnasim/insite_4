class AddOperationsTypeToTaxClasses < ActiveRecord::Migration
  def change
  	unless column_exists? :tax_classes, :operation_type
    	add_column :tax_classes, :operation_type, :string
		end
  end
end
