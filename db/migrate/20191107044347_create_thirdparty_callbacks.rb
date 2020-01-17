class CreateThirdpartyCallbacks < ActiveRecord::Migration
  def change
    create_table :thirdparty_callbacks do |t|
      t.string :callback_type
      t.text :data

      t.timestamps
    end
  end
end
