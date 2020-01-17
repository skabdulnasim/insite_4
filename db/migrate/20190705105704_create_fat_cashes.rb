class CreateFatCashes < ActiveRecord::Migration
  def change
    create_table :fat_cashes do |t|
      t.float :amount

      t.timestamps
    end
  end
end
