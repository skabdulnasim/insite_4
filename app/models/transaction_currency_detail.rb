class TransactionCurrencyDetail < ActiveRecord::Base
  attr_accessible :cash_id, :convertion_rate, :currency_id, :currency_name, :currency_symbol,:accepted_currency_id, :amount, :conversion_amount, :currency_code
  #Model association
  belongs_to :cash
  belongs_to :accepted_currency

  #Model callback
  after_create :calculate_conversion_amount

  def initialize(attributes=nil, *args)
    super
    if new_record?
      # set default values for new records only
      initialized = (attributes || {}).stringify_keys
      if !initialized.key?('currency_name')
        self.currency_name = self.accepted_currency.country_currency.currency
      end
      if !initialized.key?('currency_code')
        self.currency_code = self.accepted_currency.country_currency.currency_code
      end
      if !initialized.key?('currency_symbol')
        self.currency_symbol = self.accepted_currency.country_currency.symbol
      end  
      if !initialized.key?('convertion_rate')
        self.convertion_rate = self.accepted_currency.multiplier
      end             

    end
  end

  def calculate_conversion_amount
  	conversion_amount = self.amount * self.convertion_rate
  	self.update_column(:conversion_amount, conversion_amount) 
  end

end
