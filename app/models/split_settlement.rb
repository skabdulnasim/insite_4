class SplitSettlement < ActiveRecord::Base
  attr_accessible :settlement_id, :bill_split_ammount, :bill_id, :bill_split_id, :status, :device_id, :client_id, :client_type, :recorded_at,
                  :payments_attributes
  belongs_to :bill_split
  has_many :payments 
  belongs_to :bill
  belongs_to :settlement

  accepts_nested_attributes_for :payments
  # Validations 
  validates :bill_split, presence: true
  validates :bill_split_id, uniqueness: true
  after_create :update_split_settlement
  # Model callback
  after_save :undate_bill_split

  def initialize(attributes=nil, *args)
    super
    if new_record?
      # set default values for new records only
      initialized = (attributes || {}).stringify_keys
      if initialized.key?('bill_split_id')
        self.bill_split_ammount = self.bill_split.grand_total
        self.status = 'paid'
        self.bill_id = self.bill_split.bill_id
      end
      if !initialized.key?('recorded_at')
        self.recorded_at = Time.now.utc
      else
        self.recorded_at = self.recorded_at.utc
      end 
    end
  end

  private
  def update_split_settlement
    self.update_attributes(:device_id => self.settlement.device_id, :client_type => self.settlement.client_type, :client_id => self.settlement.client_id)
  end 

  def undate_bill_split
    self.bill_split.paid!
  end

end
