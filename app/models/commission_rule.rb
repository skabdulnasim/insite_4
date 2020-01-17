class CommissionRule < ActiveRecord::Base
  attr_accessible :month, :resource_id, :set_by, :last_updated_at, :commission_rule_inputs_attributes
  audited
  MONTHS = %w(01/2019 02/2019 03/2019 04/2019 05/2019 06/2019 07/2019 08/2019 09/2019 10/2019 11/2019 12/2019 )
  AMOUNT_TYPE = %w(by_amount by_percentage)
  
  def initialize(attributes=nil, *args)
    super
    if new_record?
      # set default values for new records only
      initialized = (attributes || {}).stringify_keys
      if !initialized.key?('last_updated_at')
        self.last_updated_at = Time.now.utc
      else
        self.last_updated_at = self.last_updated_at.utc
      end
    end
  end

  # Model Relations
  belongs_to :user, foreign_key: :set_by
  has_many :commission_rule_inputs, :dependent => :destroy
  has_many :commission_rule_outputs

  accepts_nested_attributes_for :commission_rule_inputs, allow_destroy: true

  #after_save  :modify_user_sale

  # Model Scopes
  scope :by_resource, lambda { |resource_id| where(["resource_id = ?", resource_id])}
  scope :by_month, lambda { |month| where(["month = ?", month])}
  # scope :by_resource_month_product, lambda { |resource_id, month, product_id| joins(:commission_rule_inputs).where(["commission_rules.resource_id = ? AND commission_rules.month = ? AND commission_rule_inputs.product_id = ?", resource_id,month,product_id])}

  def self.sample_commission_csv
    CSV.generate do |csv|
      csv_header = ["Resource unique id","Month","Set By","Product","Amount type","Amount"]
      csv<<csv_header
      _row=Array.new
      _row.push("123WE123")
      _row.push("01/2019")
      _row.push("mantri@silvershines.com")
      _row.push("ANKLET")
      _row.push("by_amount")
      _row.push("2")
      csv<<_row
    end
  end

  def modify_user_sale
    resource_id = self.resource_id
    month_begn = Date.parse(self.month).beginning_of_month
    month_end = Date.parse(self.month).end_of_month
    self.commission_rule_inputs.each do |inpt|
      product_id = inpt.product_id
      user_sales = UserSale.by_recorded_at_between(month_begn.to_s,month_end.to_s).by_resource_id(resource_id).by_product_id(product_id)
      user_sales.each do |user_sale|
        owner_amount = inpt.commission_rule_output.owner_commission
        csm_amount = inpt.commission_rule_output.thirdparty_commission
        user_sale.update_column(:owner_commission, owner_amount)
        user_sale.update_column(:thirdparty_commission, csm_amount)
      end
    end
    self.update_attribute(:last_updated_at, Time.now.utc)
  end

end