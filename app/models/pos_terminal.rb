class PosTerminal < ActiveRecord::Base
  attr_accessible :capability, :name, :unit_id, :properties,  :istrash

  # POS Properties
  POS_PROPERTIES = %w[menu_card_id search_type invoice_page_size sku_only_operations upc_based_operations bill_serial_prefix]

  POS_PROPERTIES.each do |key|
    define_method(key) do
      properties && properties[key]
    end
  end

  # 

  # => Model relations
  belongs_to  :unit

  CAPABILITIES = %w(self_unit self_and_child_units all_units)
  # => Dynamic methods for bill statuses
  CAPABILITIES.each do |capa|
    define_method "#{capa}?" do
      self.capability == capa
    end
  end

  # => Dynamically defining these custom finder methods
  class << self
    CAPABILITIES.each do |capa|
      define_method "#{capa}" do
        where(["capability=?", capa])
      end
    end
  end

  # => Model validations
  validates :name,          :presence => true
  validates :unit_id,       :presence => true
  validates :capability,    :presence => true
  validates :capability,    inclusion: {  in: CAPABILITIES,
                                          message: "%{value} is not a valid capability"
                                        }

  # => Model Scopes
  scope :unit_pos, lambda {|unit_id|where(["unit_id=?", unit_id])}
  scope :not_trashed,   lambda { where(:istrash => 0) }

end
