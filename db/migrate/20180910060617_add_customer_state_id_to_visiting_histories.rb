class AddCustomerStateIdToVisitingHistories < ActiveRecord::Migration
  def change
    add_column :visiting_histories, :customer_state_id, :integer
    add_column :visiting_histories, :customer_id, :integer
  end
end
