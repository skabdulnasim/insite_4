class UnitFeedback < ActiveRecord::Base
  attr_accessible :feedback_id, :unit_id

  # Model validations
  validates :unit_id, :presence => true
  validates :feedback_id, :presence => true

  # Model relations
  belongs_to :unit
  belongs_to :feedback

  def self.save_unit_feedbacks(feedback_id, unit_ids)
  	prev = self.where('feedback_id =?', feedback_id)
    prev.destroy_all if prev.present?
  	unit_ids.each do |unit_id|
  	  UnitFeedback.create(:feedback_id => feedback_id, :unit_id => unit_id)
	  end
  end
end
