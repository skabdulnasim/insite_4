class CreateVendorContracts < ActiveRecord::Migration
  def change
    create_table :vendor_contracts do |t|
      t.integer :vendor_id
      t.integer :unit_id
      t.integer :visited_by
      t.string :latitude
      t.string :longitude
      t.float :total_contract_price
      t.float :grand_total
      t.float :total_tax_amount

      t.timestamps
    end
  end
end
