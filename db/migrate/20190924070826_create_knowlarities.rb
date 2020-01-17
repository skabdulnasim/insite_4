class CreateKnowlarities < ActiveRecord::Migration
  def change
    create_table :knowlarities do |t|
      t.string :agent_phone_number
      t.string :customer_phone_number

      t.timestamps
    end
  end
end
