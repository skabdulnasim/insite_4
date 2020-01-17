class CreateCancelationPolicies < ActiveRecord::Migration
  def change
    create_table :cancelation_policies do |t|
      t.text :plolicy
      t.boolean :is_refundable
      t.string :cancelation_not_allowed_state
      t.integer :unit_id
      t.boolean :is_delivery_charge_refandable
      t.string :cancelation_charge_type
      t.float :cancelation_charge
      t.boolean :cancellation_allowed
      t.string :refund_in

      t.timestamps
    end
  end
end
