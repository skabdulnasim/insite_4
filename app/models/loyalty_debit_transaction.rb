class LoyaltyDebitTransaction < ActiveRecord::Base
  belongs_to :loyalty_card
  belongs_to :loyalty_debit, polymorphic: true
  has_one    :loyalty_card_transaction, as: :loyalty_transaction
  
  attr_accessible :loyalty_debit_transaction_type, :loyalty_card_id

  after_save  :loyalty_card_transaction_record

  def loyalty_card_transaction_record
    self.build_loyalty_card_transaction({loyalty_card_id: self.loyalty_card_id})
    self.loyalty_card_transaction.save!
  end

end
