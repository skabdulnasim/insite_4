class LoyaltyCardClass < ActiveRecord::Base
  attr_accessible :enrollment_rule,:recharge_rule,:reward_rule,:debit_rule, :name

  serialize :enrollment_rule, Hash
  serialize :recharge_rule, Hash
  serialize :reward_rule, Hash
  serialize :debit_rule, Hash

  validates :enrollment_rule, :presence => true
  validates :recharge_rule, :presence => true
  validates :reward_rule, :presence => true
  validates :debit_rule, :presence => true
  validates :name, :presence => true

  has_many :loyalty_cards

  #before_validation :set_attributes

  def set_attributes
    self.enrollment_rule[:refundable]  = false unless self.enrollment_rule[:refundable].present?
    self.recharge_rule[:refundable]  = false unless self.recharge_rule[:refundable].present?
    self.reward_rule[:refundable]  = false unless self.reward_rule[:refundable].present?
    #binding.pry
  end

  # store :purchase_rule, accessors: [ :amount, :point ], coder: JSON

  # def purchase_rule_hash
  #   self.properties.collect{|k,v| [k,v]}
  # end

  # def purchase_rule_hash=(param_hash)
  #   # need to ensure deleted values from form don't persist        
  #   self.purchase_rule.clear 
  #   param_hash.each do |name, value|
  #     self.purchase_rule[name.to_sym] = value
  #   end  
  # end


  #store :reward_rule,   accessors: [ :amount, :point ], coder: JSON
  #store :debit_rule,    accessors: [ :amount, :point ], coder: JSON

  

  
end
