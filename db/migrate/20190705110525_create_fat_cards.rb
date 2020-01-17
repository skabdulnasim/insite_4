class CreateFatCards < ActiveRecord::Migration
  def change
    create_table :fat_cards do |t|
      t.float :amount
      t.string :bank
      t.string :cvv
      t.string :merchandiser
      t.string :name_on_card
      t.string :card_no
      t.string :card_type
      t.date :valid_upto

      t.timestamps
    end
  end
end