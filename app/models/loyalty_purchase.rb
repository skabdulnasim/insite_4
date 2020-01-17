class LoyaltyPurchase < ActiveRecord::Base
  belongs_to :loyalty_card
  has_one :loyalty_credit_transaction, as: :loyalty_credit
 
  
  attr_accessible :card_identity, :point_purchase, :purchase_cost, :purchase_type, :loyalty_credit_transaction_attributes

  accepts_nested_attributes_for :loyalty_credit_transaction
  include ActiveModel::Validations
  validates :card_identity,   :card_exist=>true
  validates :loyalty_card_id, :presence => true
  validates :purchase_cost,   :presence => true
  validates :purchase_type,   :presence =>true
  
  
  def card_identity
    LoyaltyCard.find(loyalty_card_id).card_no if loyalty_card_id.present?
  end

  def card_identity=(identity)
    self.loyalty_card_id = LoyaltyCard.find_card(identity).first.id if LoyaltyCard.find_card(identity).first.present?
  end
  
  delegate :validity, :refundable, :to => :loyalty_credit_transaction

  TYPE = %w(enrollment recharge)

  TYPE.each do |type|
    define_method "#{type}?" do
      self.card_type == type
    end
  end

  # => Dynamically defining these custom finder methods for LoyaltyPurchase types
  class << self
    TYPE.each do |type|
      define_method "#{type}" do
        where(["card_type=?", type])
      end
    end
  end 

  before_save  :point_calculation
 
  def card_exist
    LoyaltyCard.find_card(self.card_identity).first.present?
  end

  private

  def point_calculation
    if self.purchase_type=="recharge"
      self.point_purchase = self.loyalty_card.recharge_point(self.purchase_cost)
    end
    
    if self.purchase_type=="enrollment"
      self.point_purchase = self.loyalty_card.enrollment_point
    end
    
    #### Update Loyalty Credit Transaction
    #self.loyalty_credit_transaction.loyalty_card_id   = self.loyalty_card_id
    #self.loyalty_credit_transaction.obtained_point    = self.point_purchase
    #self.loyalty_credit_transaction.available_point   = self.point_purchase
    #self.loyalty_credit_transaction.remarks           = self.purchase_type

  end

end
