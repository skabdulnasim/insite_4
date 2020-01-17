module LoyaltyCardsHelper
	def get_loyalty_transaction_data(card_id, from_date, to_date)
    _arr = LoyaltyCreditTransaction.get_loyalty_report_data(card_id, from_date, to_date)
  end
end
