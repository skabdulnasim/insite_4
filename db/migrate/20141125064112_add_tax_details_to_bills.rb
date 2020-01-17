class AddTaxDetailsToBills < ActiveRecord::Migration
  def change
    add_column :bills, :tax_details, :string
  end
end
