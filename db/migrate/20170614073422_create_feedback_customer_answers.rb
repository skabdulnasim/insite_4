class CreateFeedbackCustomerAnswers < ActiveRecord::Migration
  def change
    create_table :feedback_customer_answers do |t|
      t.integer :feedback_id
      t.integer :feedback_option_id
      t.integer :feedback_customer_id

      t.timestamps
    end
  end
end
