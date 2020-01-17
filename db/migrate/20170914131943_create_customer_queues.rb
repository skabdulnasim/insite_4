class CreateCustomerQueues < ActiveRecord::Migration
  def change
    create_table :customer_queues do |t|
      t.string :from_date
      t.string :to_date

      t.timestamps
    end
  end
end
