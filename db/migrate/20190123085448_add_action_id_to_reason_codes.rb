class AddActionIdToReasonCodes < ActiveRecord::Migration
  def change
    add_column :reason_codes, :action_id, :integer
    add_column :reason_codes, :reason, :text
  end
end
