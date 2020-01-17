class CashOutDescription < ActiveRecord::Base
  attr_accessible :cash_out_id, :count, :denomination_id
  belongs_to :cash_out
  belongs_to :denomination
end
