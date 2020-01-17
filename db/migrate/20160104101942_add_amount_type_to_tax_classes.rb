class AddAmountTypeToTaxClasses < ActiveRecord::Migration
  def change
    add_column :tax_classes, :amount_type, :string, :default => "percentage"
    add_column :tax_groups, :fixed_amount, :float, :default => 0
    execute 'ALTER TABLE tax_classes ALTER COLUMN ammount TYPE float USING (ammount::float)'
  end
end
