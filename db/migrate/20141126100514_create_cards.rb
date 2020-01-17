class CreateCards < ActiveRecord::Migration
  def change
    create_table :cards do |t|
      t.string :no
      t.date :valid_upto
      t.string :type
      t.string :bank
      t.integer :cvv
      t.string :merchandiser
      t.string :name_on_card
      t.integer :amount

      t.timestamps
    end
  end
end
