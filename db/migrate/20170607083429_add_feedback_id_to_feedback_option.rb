class AddFeedbackIdToFeedbackOption < ActiveRecord::Migration
  def change
    add_column :feedback_options, :feedback_id, :integer
  end
end
