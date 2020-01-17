class LoyaltyCardTransaction < ActiveRecord::Base
  belongs_to :loyalty_card
  belongs_to :loyalty_transaction, polymorphic: true

  attr_accessible :loyalty_card_id,:loyalty_transaction_id,:loyalty_transaction_type

  validates :loyalty_card_id, :presence => true

  #model scope
  scope :set_loyalty_card,  lambda {|loyalty_card_id|where(["loyalty_card_id=?", loyalty_card_id])}
  def self.check_redeem_report_date_range(from_date,upto_date)
    data = ActiveRecord::Base.connection.execute("SELECT loyalty_cards.name_on_card,loyalty_cards.card_no, date(loyalty_card_transactions.created_at) as created_at,round(CAST(SUM(loyalty_card_transactions.points) as numeric),2) as total_points, round(CAST(SUM(loyalty_card_transactions.transaction_amount) as numeric),2) as total_transaction_amount FROM loyalty_card_transactions 
      LEFT OUTER JOIN loyalty_cards ON loyalty_card_transactions.loyalty_card_id = loyalty_cards.id 
      where loyalty_card_transactions.remarks = 'redeem' AND loyalty_card_transactions.created_at BETWEEN '#{from_date}' AND '#{upto_date}'
      GROUP BY loyalty_card_transactions.loyalty_card_id,date(loyalty_card_transactions.created_at),loyalty_cards.name_on_card,loyalty_cards.card_no");
  end

  def self.loyalty_card_report_to_csv(sales)
    CSV.generate do |csv|
      _title = ["Card No", "User Name", "Points", "Transaction Amount", "Date Time" ]
      csv << _title
      sales.each do |sale|
        _row = Array.new
        _row.push(sale["card_no"])
        _row.push(sale["name_on_card"])
        _row.push(sale["total_points"])
        _row.push(sale["total_transaction_amount"])
        _row.push(sale["created_at"])
        csv << _row
      end
    end
  end

  def self.loyalty_card_use_report_to_csv(loyalty_cards,from_date, to_date)
    CSV.generate do |csv|
      _title = ["Card Serial", "Name on Card", "Card Recharge", "Usage", "Pending Amount" ]
      csv << _title
      loyalty_cards.each do |object|
        loyalty_card_data = LoyaltyCreditTransaction.get_loyalty_report_data(object.loyalty_card_id, from_date, to_date)
        _row = Array.new
        _row.push(loyalty_card_data[:card_serial])
        _row.push(loyalty_card_data[:name_on_card])
        _row.push(object.total_obtained_point)
        _row.push(loyalty_card_data[:loyalty_poins_used])
        _row.push(object.total_available_point)
        csv << _row
      end
    end
  end

  def Credit?
    self.loyalty_transaction_type == "LoyaltyCreditTransaction"
  end

  def Debit?
    self.loyalty_transaction_type == "LoyaltyDebitTransaction"
  end

  def self.by_created_at(from_date, upto_date)    
    where('loyalty_card_transactions.created_at BETWEEN ? AND ?',from_date,upto_date)
  end

  private

  def credit_transaction
    eq_points_recharge = (self.loyalty_card.loyalty_card_class.recharge_rule[:point].to_f/self.loyalty_card.loyalty_card_class.recharge_rule[:amount].to_f)*self.transaction_amount if self.remarks=="recharge"
    eq_points_reward =   (self.loyalty_card.loyalty_card_class.reward_rule[:point].to_f/self.loyalty_card.loyalty_card_class.reward_rule[:amount].to_f)*self.transaction_amount if self.remarks=="reward"
    eq_points_enrollment =   (self.loyalty_card.loyalty_card_class.enrollment_rule[:point].to_f/self.loyalty_card.loyalty_card_class.enrollment_rule[:amount].to_f)*self.transaction_amount if self.remarks=="enrollment"
   
    self.points = eq_points_recharge || eq_points_reward || eq_points_enrollment
    self.points_after_transaction = (self.loyalty_card.points || 0) + self.points
    #binding.pry
    self.loyalty_card.points = self.points_after_transaction
    self.loyalty_card.save
  end
  
  def debit_transaction
    
    eq_points = (self.loyalty_card.loyalty_card_class.debit_rule[:point].to_f/self.loyalty_card.loyalty_card_class.debit_rule[:amount].to_f)*self.transaction_amount 
    self.points = eq_points
    self.points_after_transaction = self.loyalty_card.points - self.points
  
    self.loyalty_card.points = self.points_after_transaction
    self.loyalty_card.save
  end

end
