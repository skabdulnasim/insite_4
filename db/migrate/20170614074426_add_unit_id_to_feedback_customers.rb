class AddUnitIdToFeedbackCustomers < ActiveRecord::Migration
  def change
    add_column :feedback_customers, :unit_id, :integer
  end
end
