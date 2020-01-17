class OwnCustomer < ActiveRecord::Base
  attr_accessible :customer_unique_id, :email, :mobile_no, :name, :own_customer_addresses_attributes, :customer_queues_attributes

  #validates :customer_unique_id, :uniqueness => true
  #validates :email, :uniqueness => true
  validates :mobile_no, :uniqueness => true, :length => { :minimum => 10, :maximum => 12 }, :numericality => true

  has_many :customer_queues
  has_many :reservations
  has_many :own_customer_addresses
  accepts_nested_attributes_for :own_customer_addresses
  accepts_nested_attributes_for :customer_queues

  scope :by_login, lambda {|login|where(["email = :email or mobile_no = :mobile_no", {email: login, mobile_no: login}])}
  scope :get_all, lambda { order('id desc') }
end
