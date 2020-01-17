class AddCancelationAllowedSinceDeliverableToCancelationPolicies < ActiveRecord::Migration
  def change
    add_column :cancelation_policies, :cancelation_allowed_since_deliverable, :string
  end
end
