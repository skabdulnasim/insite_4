class CreateVendorProductPrices < ActiveRecord::Migration
  def change
    create_table :vendor_product_prices do |t|
    	t.integer :vendor_product_id
      t.integer :vendor_id
      t.integer :product_id
      t.float   :price_without_tax
      t.float   :price_with_tax
      t.text 		:tax_details
      t.text    :address_of_place
      t.string  :latitude
      t.string  :longitude
      t.date 		:delivery_starts
      t.date 		:delivery_ends
      t.string  :delivery_distance
      t.float  	:delivery_rate_per_km
      t.float  	:delivery_cost
      t.float		:discount
      t.float		:quantity
      t.float		:cost
      t.integer :reported_by
      t.integer :viwed_by
      t.string  :status

      t.timestamps
    end
  end
end