class AddTotalAmntToTaxGroups < ActiveRecord::Migration
  def change
    add_column :tax_groups, :total_amnt, :float, :default => 0
  end
end
