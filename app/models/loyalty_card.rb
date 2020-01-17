class LoyaltyCard < ActiveRecord::Base
  attr_accessible :card_no,:loyalty_card_class_id, :card_serial, :card_type, :customer_id, :name_on_card, :points, :status, :valid_from, :valid_till, :equivalent_money
  
  ### =>  Model Relations
  belongs_to  :customer
  belongs_to  :loyalty_card_class
  has_many    :loyalty_card_transactions
  has_many    :loyalty_purchases
  has_many    :loyalty_credit_transactions 

    #where(["card_no = :card_no OR card_serial = :card_serial",{card_no: card_identity,card_serial: card_identity}]).first
  scope :find_card, lambda{|card_identity| where(["card_no = :card_no OR card_serial = :card_serial",{card_no: card_identity,card_serial: card_identity}])}
  scope :by_customer_id, lambda{|customer_id| where(["customer_id=?", customer_id])}

  #delegate :name, :to => :loyalty_card_class, :prefix => "card_class"

  ### =>  Fixed Constants and its dynamic methods
  # => Defining LoyaltyCard Statuses
  STATUS = %w(active inactive)
  
  # => Dynamic methods for LoyaltyCard statuses
  STATUS.each do |status|
    define_method "#{status}?" do
      self.status == status
    end
  end

  # => Dynamically defining these custom finder methods for LoyaltyCard statuses
  class << self
    STATUS.each do |status|
      define_method "#{status}" do
        where(["status=?", status])
      end
    end
  end

  # => Defining LoyaltyCard Types
  TYPE = %w(paid complimentary corporate)
  
  # => Dynamic methods for LoyaltyCard types
  TYPE.each do |type|
    define_method "#{type}?" do
      self.card_type == type
    end
  end

  # => Dynamically defining these custom finder methods for LoyaltyCard types
  class << self
    TYPE.each do |type|
      define_method "#{type}" do
        where(["card_type=?", type])
      end
    end
  end 

  def card_class
    self.loyalty_card_class.name
  end

  # => Defining LoyaltyCard Statuses
  #CLASS = %w(platinum gold silver)
  
  # => Dynamic methods for LoyaltyCard classes
  # CLASS.each do |card_class|
  #   define_method "#{card_class}?" do
  #     self.card_class == card_class
  #   end
  # end

  # => Dynamically defining these custom finder methods for LoyaltyCard classes
  # class << self
  #   CLASS.each do |card_class|
  #     define_method "#{card_class}" do
  #       where(["card_class=?", card_class])
  #     end
  #   end
  # end

  ### => Model Callbacks
  #before_validation :generate_card_serial

  ### => Model Validations
  validates :name_on_card,        :presence => true, 
                                  :length => { :maximum => 250 }  
  validates :status,              :presence => true, 
                                  :inclusion => {:in => STATUS, :message => "%{value} is not a valid status" }
  validates :card_type,           :presence => true, 
                                  :inclusion => {:in => TYPE, :message => "%{value} is not a valid card type" }
  validates :loyalty_card_class_id,  :presence => true
                                                     
  validates :customer_id,         :presence => true,
                                  :uniqueness => true
  validates :valid_from,          :presence => true
  validates :valid_till,          :presence => true
  validates :card_serial,         :presence => true,
                                  #:length => { :maximum => 12 },
                                  :uniqueness => true
  validates :card_no,             :presence => true,
                                  #:length => { :max => 12 },
                                  :uniqueness => true
  
  def valid_points
    self.loyalty_credit_transactions.valid_points
  end
  
  def debit_account(point)
    oldest_entry = self.valid_points.first
    if point <= oldest_entry.available_point
      oldest_entry.update_column(:available_point, oldest_entry.available_point - point)
      due_paymnet = 0
      return
    else
      due_paymnet =  point - oldest_entry.available_point
      oldest_entry.update_column(:available_point, 0)
      debit_account(due_paymnet)  
    end
  end

  def to_point(amount)
    (self.loyalty_card_class.debit_rule[:point].to_f/self.loyalty_card_class.debit_rule[:amount].to_f)*amount
  end

  
  
  def total_valid_point
    self.loyalty_credit_transactions.valid_points.sum(:available_point)
  end
  
  def total_valid_amount
    (self.loyalty_card_class.debit_rule[:amount].to_f/self.loyalty_card_class.debit_rule[:point].to_f)*self.total_valid_point 
  end

  def amount_available?(amount)
    self.total_valid_amount >= amount
  end

  def point_available?(point)
    self.total_valid_point >= point
  end
  
  # def self.find_card(card_identity)
  #   where(["card_no = :card_no OR card_serial = :card_serial",{card_no: card_identity,card_serial: card_identity}]).first
  # end

  def reward_point(amount)
    reward_point = (self.loyalty_card_class.reward_rule[:point].to_f/self.loyalty_card_class.reward_rule[:amount].to_f)*amount 
    (reward_point.is_a?(Float) && reward_point.nan?) ? 0 : reward_point
  end

  def recharge_point(amount)
    (self.loyalty_card_class.recharge_rule[:point].to_f/self.loyalty_card_class.recharge_rule[:amount].to_f)*amount
  end

  def enrollment_point(amount)
    (self.loyalty_card_class.enrollment_rule[:point].to_f/self.loyalty_card_class.enrollment_rule[:amount].to_f)*amount
  end

  def to_debit_point(amount)
    (self.loyalty_card_class.debit_rule[:point].to_f/self.loyalty_card_class.debit_rule[:amount].to_f)*amount
  end

  def to_debit_amount(point)
    (self.loyalty_card_class.debit_rule[:amount].to_f/self.loyalty_card_class.debit_rule[:point].to_f)*point
  end
  
  private

  # => Card Serial No. generator
  def generate_card_serial
    self.card_serial = get_random_number
  end

  # => Custom date validator
  def validate_date_format
    if !valid_from.is_a?(Date)
      errors.add(:valid_from, 'must be a valid date') 
    end
    if !valid_till.is_a?(Date)
      errors.add(:valid_till, 'must be a valid date') 
    end    
  end

  # => Getting unique random number for card serial
  def get_random_number
    _number = (rand(100000000000..999999999999)).to_s
    _card = LoyaltyCard.find_by_card_serial(_number)
    if _card.present?
      get_random_number
    else
      return _number
    end
  end
end
