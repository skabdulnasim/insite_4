class CreateCountryCurrencies < ActiveRecord::Migration
  def change
    create_table :country_currencies do |t|
      t.string :counrty
      t.string :currency
      t.string :currency_code
      t.string :sybmol

      t.timestamps
    end
  end
end
