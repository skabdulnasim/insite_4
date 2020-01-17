class CashInDescription < ActiveRecord::Base
  attr_accessible :cash_in_id, :count, :denomination_id
  belongs_to :cash_in
  belongs_to :denomination

  
end
