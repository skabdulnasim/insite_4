class ChangeColumnFeedbackCustomerIdToCustomerFeedbackId < ActiveRecord::Migration
  def up
  	rename_column :customer_feedback_answers, :feedback_customer_id, :customer_feedback_id
  end
end
