class CreateThirdPartyPaymentOptions < ActiveRecord::Migration
  def change
    create_table :third_party_payment_options do |t|
      t.string :name
      t.string :status
      t.boolean :is_trashed

      t.timestamps
    end
  end
end
