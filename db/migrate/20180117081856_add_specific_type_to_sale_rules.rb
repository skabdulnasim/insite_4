class AddSpecificTypeToSaleRules < ActiveRecord::Migration
  def change
    add_column :sale_rules, :specific_type, :string
  end
end
