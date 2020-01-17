class CreateFeedbackCustomers < ActiveRecord::Migration
  def change
    create_table :feedback_customers do |t|
      t.string :name
      t.string :phone
      t.string :email

      t.timestamps
    end
  end
end
