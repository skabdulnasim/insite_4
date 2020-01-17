class CreatePayments < ActiveRecord::Migration
  def change
    create_table :payments do |t|
      t.integer :settlement_id
      t.references :paymentmod, polymorphic: true

      t.timestamps
    end
  end
end
