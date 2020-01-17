class ReasonCode < ActiveRecord::Base
  attr_accessible :code, :status, :stock_adjustment, :model_action_id, :reason
  belongs_to :model_action

  #Model callback
  after_create :genarate_code

  def genarate_code
  	self.update_attribute(:code, build_code)
  end

  def build_code
  	"#{self.model_action.master_model.name.upcase[0..-2]}""00""#{self.id}"
  end
end
