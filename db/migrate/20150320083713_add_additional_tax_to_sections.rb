class AddAdditionalTaxToSections < ActiveRecord::Migration
  def change
    add_column :sections, :additional_tax, :float, :default => 0
  end
end
