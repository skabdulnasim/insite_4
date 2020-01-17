class PaytmSecurity < ActiveRecord::Base
  attr_accessible :channel_id, :industry_type_id, :mid, :paytm_marchant_key, :paytm_url, :website

  validates	:channel_id, :presence => true
  validates :industry_type_id, :presence => true
  validates :mid, :presence => true
  validates :paytm_marchant_key, :presence => true
  validates :paytm_url, :presence => true
  validates :website, :presence => true 
end
