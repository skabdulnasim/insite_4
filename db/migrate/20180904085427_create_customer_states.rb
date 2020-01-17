class CreateCustomerStates < ActiveRecord::Migration
  def change
    create_table :customer_states do |t|
      t.string :name

      t.timestamps
    end
  end
end
