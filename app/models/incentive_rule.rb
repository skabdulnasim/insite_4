class IncentiveRule < ActiveRecord::Base
  attr_accessible :achivement_lower_range, :achivement_range_type, :achivement_upper_range, :incentive_amount, :avg_incentive_amount, :role_id
  audited
  before_save :check_valid_incentive

  # => Model relations
  belongs_to  :role

  scope :for_validation, lambda { |role_id, achivement_range_type, set_range| where(["role_id = ? AND achivement_range_type = ? AND ? BETWEEN achivement_lower_range AND achivement_upper_range", role_id, achivement_range_type, set_range]) }
  scope :by_role_and_range_type, lambda { |role_id, achivement_range_type| where(["role_id = ? AND achivement_range_type = ?", role_id, achivement_range_type]) }
  scope :not_id, lambda { |incentive_id| where(["id <> ?", incentive_id]) }

  ACHIVEMENT_TYPE = %w(percent amount quantity)

  private

  def check_valid_incentive
  	available = self.id.present? ? IncentiveRule.for_validation(self.role_id, self.achivement_range_type, self.achivement_lower_range).not_id(self.id) : IncentiveRule.for_validation(self.role_id, self.achivement_range_type, self.achivement_lower_range)
  	available2 = self.id.present? ? IncentiveRule.for_validation(self.role_id, self.achivement_range_type, self.achivement_upper_range).not_id(self.id) : IncentiveRule.for_validation(self.role_id, self.achivement_range_type, self.achivement_upper_range)
    incentive_by_role_type = self.id.present? ? IncentiveRule.by_role_and_range_type(self.role_id, self.achivement_range_type).not_id(self.id) : IncentiveRule.by_role_and_range_type(self.role_id, self.achivement_range_type)
  	mmin = incentive_by_role_type.minimum(:achivement_lower_range)
  	mmax = incentive_by_role_type.maximum(:achivement_upper_range)
  	raise 'Incentive lower range or upper range for this rule already exist.' if available.count > 0
  	raise 'Incentive lower range or upper range for this rule already exist.' if available2.count > 0
  	raise 'Invalid incentive rule.' if self.achivement_lower_range > self.achivement_upper_range
    if incentive_by_role_type.count > 0
      raise 'Incentive rule range already exist.' if self.achivement_lower_range <= mmin && self.achivement_upper_range >= mmax
    end
  end
end
