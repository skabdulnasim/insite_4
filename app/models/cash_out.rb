class CashOut < ActiveRecord::Base
  attr_accessible :amount, :user_id, :reason, :device_id, :unit_id, :recorded_at, :cash_out_descriptions_attributes
  has_many :pays, as: :pay_transaction
  has_many :cash_out_descriptions
  has_many :denominations
  after_create :update_cash_out
  accepts_nested_attributes_for :cash_out_descriptions, reject_if: proc { |attributes| attributes['count'].blank? }

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
  
  def update_cash_out
    Pay.cash_save(self.id,"cash_out","0",self.amount,self.amount,self.user_id,self.unit_id,self.device_id)
  end
end



