class StockProduction < ActiveRecord::Base
  attr_accessible :kitchen_store_id, :status, :store_id, :isStockAdded, :production_date, :start_date, :end_date
  # => Defining relations

  def initialize(attributes=nil, *args)
    super 
    if new_record?
      initialized = (attributes || {}).stringify_keys
      if !initialized.key?('start_date')
        self.start_date = Time.now.utc

      end    
      if !initialized.key?('end_date')
        self.end_date = Time.now.utc + 2
      end
    end
  end
  has_many :stock_production_metas
  has_many :stocks, as: :stock_transaction
  belongs_to :store
  belongs_to :kitchen_store, :class_name => "StockProduction", :foreign_key => "kitchen_store_id"

  # => Model validations
  validates :kitchen_store_id,  :presence => true
  validates :store_id,          :presence => true
  validates :status,            :presence => true

  # => Model scopes
  scope :desc_order, lambda { order("created_at desc") }
  scope :processing, lambda { where(:status => '1') }
  scope :processed, lambda { where(:status => '2') }

  private

end