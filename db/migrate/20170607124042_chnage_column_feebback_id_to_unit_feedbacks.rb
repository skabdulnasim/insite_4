class ChnageColumnFeebbackIdToUnitFeedbacks < ActiveRecord::Migration
  def up
  	rename_column :unit_feedbacks, :feebback_id, :feedback_id
  end
end
