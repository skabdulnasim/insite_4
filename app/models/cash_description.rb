class CashDescription < ActiveRecord::Base
  attr_accessible :cash_id, :count, :denomination_id 
  belongs_to :cash
end

