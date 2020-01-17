class RenameFeedbackCustomersToCustomerFeedbacks < ActiveRecord::Migration
  def up
  	rename_table :feedback_customers, :customer_feedbacks
  	rename_table :feedback_customer_answers, :customer_feedback_answers
  end
end
