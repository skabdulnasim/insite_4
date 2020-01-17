class ThirdPartyPaymentOption < ActiveRecord::Base
  attr_accessible :name, :is_trashed, :status
end
