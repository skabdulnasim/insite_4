class AcceptedCurrency < ActiveRecord::Base
  attr_accessible :country_currency_id, :multiplier,:status
  belongs_to :country_currency
end
