class CashIn < ActiveRecord::Base
  attr_accessible :amount, :user_id, :reason, :unit_id, :device_id, :recorded_at, :bill_serial_no,:cash_in_descriptions_attributes
  has_many :pays, as: :pay_transaction
  has_many :denomination
  has_many :cash_in_descriptions
  belongs_to :payment
  after_create :update_cash_in
  belongs_to :user
  accepts_nested_attributes_for :cash_in_descriptions, reject_if: proc { |attributes| attributes['count'].blank? }

  def initialize(attributes=nil, *args)
    super
    if new_record?
      # set default values for new records only
      initialized = (attributes || {}).stringify_keys
      if !initialized.key?('recorded_at')
        self.recorded_at = Time.now.utc
      else
        self.recorded_at = self.recorded_at.utc
      end
    end
  end
  def self.save_into_cash_in(unit_id,user_id,grand_total,reason,device_id,recorded_at,serial_no,cash_id)
    _new_cash_in = CashIn.new
    _new_cash_in.unit_id = unit_id
    _new_cash_in.user_id = user_id
    _new_cash_in.amount = grand_total
    _new_cash_in.reason = reason
    _new_cash_in.device_id = device_id
    _new_cash_in.recorded_at = recorded_at
    _new_cash_in.bill_serial_no = serial_no 
    _new_cash_in.save!
    save_cash_in_descriptions(cash_id,_new_cash_in.id)
  end 

  def self.save_cash_in_descriptions(cash_id,cash_in_id)
    cash = Cash.find(cash_id)
    cash_descriptions = cash.cash_descriptions
    if cash_descriptions.present?
      cash_descriptions.each do |cd|
        cash_in_description = CashInDescription.new()
        cash_in_description[:cash_in_id] = cash_in_id
        cash_in_description[:count] = cd.count
        cash_in_description[:denomination_id] = cd.denomination_id
        cash_in_description.save
      end  
    end  
  end  

  def update_cash_in
    Pay.cash_save(self.id,"cash_in",self.amount,"0",self.amount,self.user_id,self.unit_id,self.device_id)
  end
end




