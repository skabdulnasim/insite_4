class AddModelActionIdToReasonCodes < ActiveRecord::Migration
  def change
    add_column :reason_codes, :model_action_id, :integer
  end
end
