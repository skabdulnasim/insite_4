class LoyaltyCreditTransaction < ActiveRecord::Base
  belongs_to :loyalty_card
  belongs_to :loyalty_credit, polymorphic: true
  has_one    :loyalty_card_transaction, as: :loyalty_transaction
  attr_accessible :available_money, :available_point, :loyalty_credit_type, :obtained_money, :obtained_point, :refundable, :remarks, :validity, :card_identity

  # include ActiveModel::Validations
  # validates :card_identity,   :card_exist=>true
  # validates :loyalty_card_id, :presence => true

  #model scope
  scope :set_loyalty_card,  lambda {|loyalty_card_id|where(["loyalty_card_id=?", loyalty_card_id])}
  scope :remarks_reward, lambda { where(["remarks = ? ",'reward']) }
  scope :remarks_recharge, lambda { where(["remarks = ? ",'recharge']) }

  def card_identity
    LoyaltyCard.find(loyalty_card_id).card_no if loyalty_card_id.present?
  end

  def card_identity=(identity)
    self.loyalty_card_id = LoyaltyCard.find_card(identity).first.id if LoyaltyCard.find_card(identity).first.present?
  end

  def point_alive?
    self.validity > Time.now if self.validity.present? || true
  end

  CREDIT_TYPE = %w(Settlement LoyaltyPurchase)
  
  CREDIT_TYPE.each do |type|
    define_method "#{type}?" do
      self.loyalty_credit_type == type
    end
  end

  class << self
    CREDIT_TYPE.each do |type|
      define_method "#{type}" do
        where(["loyalty_credit_type=?", type])
      end
    end
  end 
  scope :valid_points, -> {where("validity > ? AND available_point > 0",Time.now).order("validity")}
  
  before_save :purchase_record,  :if => :LoyaltyPurchase?
  before_save :reward_record,    :if => :Settlement?

  after_create  :loyalty_card_transaction_record

  def purchase_record
    self.loyalty_card_id = self.loyalty_credit.loyalty_card_id
    if self.loyalty_credit.purchase_type =="recharge"
      self.obtained_point    = self.loyalty_card.recharge_point(self.loyalty_credit.purchase_cost)
      self.available_point   = self.obtained_point
      self.remarks           = self.loyalty_credit.purchase_type
    end

    if self.loyalty_credit.purchase_type =="enrollment"
      self.obtained_point     = self.loyalty_card.enrollment_point(self.loyalty_credit.purchase_cost)
      self.available_point    = self.obtained_point
      self.remarks            = self.loyalty_credit.purchase_type
    end
  end

  def reward_record
    _obtained_point = self.loyalty_card.reward_point(self.loyalty_credit.bill_amount)

    #if _obtained_point>0
      day_closing_time       = self.loyalty_credit.bill.unit.unit_detail.options[:day_closing_time].to_i.hours if self.loyalty_credit.bill.unit.unit_detail.present?
      self.obtained_point    = _obtained_point
      self.available_point   = self.obtained_point
      self.remarks           = "reward"
      self.refundable        = self.loyalty_card.loyalty_card_class.reward_rule[:refundable] || false
      self.validity          = self.loyalty_card.loyalty_card_class.reward_rule[:validity].to_i.days.from_now.end_of_day + (day_closing_time || 0)
    #end
    # validity_days.days.from_now.end_of_day + current_user.unit.unit_detail.options[:day_closing_time].to_i.hours
  end

  def loyalty_card_transaction_record
    self.build_loyalty_card_transaction({loyalty_card_id: self.loyalty_card_id})
    self.loyalty_card_transaction.save!
  end

  def self.by_created_at(from_date, upto_date)    
    where('loyalty_credit_transactions.created_at BETWEEN ? AND ?',from_date,upto_date)
  end
  
  def self.check_reward_report_date_range(from_date,upto_date)
    data = ActiveRecord::Base.connection.execute("SELECT loyalty_cards.name_on_card,loyalty_cards.card_no, date(loyalty_credit_transactions.created_at) as created_at,round(CAST(SUM(loyalty_credit_transactions.obtained_point) as numeric),2) as total_points FROM loyalty_credit_transactions 
      LEFT OUTER JOIN loyalty_cards ON loyalty_credit_transactions.loyalty_card_id = loyalty_cards.id 
      where loyalty_credit_transactions.remarks = 'reward' AND loyalty_credit_transactions.created_at BETWEEN '#{from_date}' AND '#{upto_date}'
      GROUP BY loyalty_credit_transactions.loyalty_card_id,date(loyalty_credit_transactions.created_at),loyalty_cards.name_on_card,loyalty_cards.card_no");
  end

  def self.get_loyalty_report_data(loyalty_card_id, from_date, to_date)
    card_details = LoyaltyCard.find(loyalty_card_id)
    loyalty_poins_used = LoyaltyCardPayment.select("sum(points_used) as loyalty_points").by_created_at(from_date,to_date).set_loyalty_card(loyalty_card_id).first
    _arr = {}
    _arr[:card_serial] = card_details.card_serial.present? ? card_details.card_serial : 0
    _arr[:name_on_card] = card_details.name_on_card.present? ? card_details.name_on_card : 0
    _arr[:loyalty_poins_used] = loyalty_poins_used.loyalty_points.present? ? loyalty_poins_used.loyalty_points : 0
    return _arr
  end

  def self.loyalty_card_points_accumulation_to_csv(loyalty_scope)
    CSV.generate do |csv|
      _title = ["Card Serial", "Name on Card", "Membership point", "Redemption", "Date" ]
      csv << _title
      loyalty_scope.each do |object|
        _row = Array.new
        loyalty_card = LoyaltyCard.find(object.loyalty_card_id)
        _row.push(loyalty_card.card_serial)
        _row.push(loyalty_card.name_on_card)
        _row.push(object.total_obtained_point)
        _row.push(object.total_available_point)
        _row.push(object.total_obtained_point.to_i - object.total_available_point.to_i)
        csv << _row
      end
    end
  end

  def self.loyalty_card_report_to_csv(sales)
    CSV.generate do |csv|
      _title = ["Card No", "User Name", "Points", "Date" ]
      csv << _title
      sales.each do |sale|
        _row = Array.new
        _row.push(sale["card_no"])
        _row.push(sale["name_on_card"])
        _row.push(sale["total_points"])
        _row.push(sale["created_at"])
        csv << _row
      end
    end
  end
end
