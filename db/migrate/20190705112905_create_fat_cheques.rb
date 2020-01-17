class CreateFatCheques < ActiveRecord::Migration
  def change
    create_table :fat_cheques do |t|
      t.string :cheque_no
      t.string :bank_name
      t.float :amount

      t.timestamps
    end
  end
end
