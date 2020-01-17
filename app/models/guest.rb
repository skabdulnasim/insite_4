class Guest < ActiveRecord::Base
  attr_accessible :email, :mobile_no, :party_code, :party_id
  #Model relation
  belongs_to :party
end
