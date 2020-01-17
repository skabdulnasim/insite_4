class UserBit < ActiveRecord::Base
  attr_accessible :bit_id, :user_id, :visit_date
  belongs_to :bit
  belongs_to :user
  belongs_to :bit

  scope :by_user, lambda{|user| where(["user_id =?",user])}
  scope :by_date, lambda { |date| where(["visit_date = ?",date]) }
end

