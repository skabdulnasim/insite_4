  class LoyaltyCardPayment < ActiveRecord::Base
  attr_accessible :amount, :loyalty_card_id, :name_on_card, :points_used, :card_identity

  ### => Model Relations
  belongs_to :loyalty_card
  has_one :loyalty_debit_transaction, as: :loyalty_debit
  has_one :payment, as: :paymentmode

  ### => Model Validations
  include ActiveModel::Validations
  validates :card_identity,   :card_exist=>true
  validates :loyalty_card_id, :presence => true
  validates :amount,          :presence => true

  ### => Model Callbacks
  before_validation :set_extra_attributes
  after_create      :debit_transaction

  # Model Scope
  scope :set_loyalty_card,  lambda {|loyalty_card_id|where(["loyalty_card_id=?", loyalty_card_id])}

  def card_identity
    LoyaltyCard.find(loyalty_card_id).card_no if loyalty_card_id.present?
  end

  def card_identity=(identity)
    self.loyalty_card_id = LoyaltyCard.find_card(identity).first.id if LoyaltyCard.find_card(identity).first.present?
  end

  def self.by_created_at(from_date, upto_date)    
    where('loyalty_card_payments.created_at BETWEEN ? AND ?',from_date,upto_date)
  end

  def self.check_redeem_report_date_range(from_date,upto_date)
    data = ActiveRecord::Base.connection.execute("SELECT loyalty_cards.name_on_card,loyalty_cards.card_no, date(loyalty_card_payments.created_at) as created_at,round(CAST(SUM(loyalty_card_payments.points_used) as numeric),2) as total_points, round(CAST(SUM(loyalty_card_payments.amount) as numeric),2) as total_transaction_amount FROM loyalty_card_payments 
      LEFT OUTER JOIN loyalty_cards ON loyalty_card_payments.loyalty_card_id = loyalty_cards.id 
      where loyalty_card_payments.created_at BETWEEN '#{from_date}' AND '#{upto_date}'
      GROUP BY loyalty_card_payments.loyalty_card_id,date(loyalty_card_payments.created_at),loyalty_cards.name_on_card,loyalty_cards.card_no");
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

  private

  def debit_transaction
    loyalty_card = LoyaltyCard.find(self.loyalty_card_id)
    self.points_used = loyalty_card.to_debit_point(self.amount)
    
    self.build_loyalty_debit_transaction({loyalty_card_id: self.loyalty_card_id})
    self.save
    loyalty_card.debit_account(self.points_used)
  end

  def set_extra_attributes
    self.name_on_card = self.loyalty_card.name_on_card
  end  

end