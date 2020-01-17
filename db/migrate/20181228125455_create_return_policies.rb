class CreateReturnPolicies < ActiveRecord::Migration
  def change
    create_table :return_policies do |t|
      t.boolean :return_allowed
      t.text :policy
      t.string :return_alowed_on_order_state
      t.boolean :is_delivery_charge_refandable
      t.integer :unit_id
      t.string :return_allowed_after_deliverable
      t.string :return_charge_type
      t.float :return_charge
      t.boolean :is_delivery_charge_refandable
      t.boolean :is_refundable

      t.timestamps
    end
  end
end
