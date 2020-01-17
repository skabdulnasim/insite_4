class CreateBillByBillSales < ActiveRecord::Migration
  def change
    create_table :bill_by_bill_sales do |t|
      t.integer :bill_id
      t.float :bill_amount
      t.float :discount
      t.float :grand_total
      t.string :status
      t.integer :deliverable_id
      t.string :deliverable_type
      t.string :deliverable_to
      t.float :tax_amount
      t.integer :unit_id
      t.integer :user_id
      t.string :device_id
      t.string :serial_no
      t.integer :pax
      t.string :remarks
      t.float :roundoff
      t.string :biller_type
      t.integer :biller_id
      t.datetime :recorded_at
      t.integer :customer_id
      t.float :boh_amount
      t.string :resource_type
      t.float :advance_payment
      t.float :delivery_charges
      t.integer :section_id
      t.integer :bill_destination_id
      t.string :lite_device_id
      t.string :is_service_charge
      t.string :suffix
      t.string :prefix
      t.float :bill_discount_percentage
      t.integer :proforma_id
      t.integer :reservation_id
      t.text :biller
      t.text :customer
      t.text :orders
      t.text :order_details
      t.text :payments
      t.text :bill_discounts
      t.text :bill_taxes
      t.text :section
      t.text :unit
      t.text :order_detail_combinations
      t.timestamps
    end
  end
end
