class CreateFatBanks < ActiveRecord::Migration
  def change
    create_table :fat_banks do |t|
      t.float :amount
      t.string :bank_name
      t.string :identity
      t.string :mode

      t.timestamps
    end
  end
end
