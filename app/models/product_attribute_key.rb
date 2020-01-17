class ProductAttributeKey < ActiveRecord::Base
  acts_as_paranoid
  acts_as_list

  attr_accessible :attribute_code, :default_value, :input_type, :is_comparable, :is_required, :is_sortable, :is_system_entity, :is_unique, :is_for_variable_product, :label, :position, 
                  :product_attribute_options_attributes

  # => Defining input types
  INPUT_TYPE = %w(text_field text_area number_field select date_field file_field check_box)

  # => Relations
  has_and_belongs_to_many :product_attribute_groups
  has_many :product_attribute_options
  has_many :options, :class_name => "ProductAttributeOption", :foreign_key => "product_attribute_key_id"
  has_many :default_options,  ->{where(:is_default => true)}, :class_name => "ProductAttributeOption", :foreign_key => "product_attribute_key_id"

  accepts_nested_attributes_for :product_attribute_options, allow_destroy: true
  # => Validations
  validates :attribute_code,  :presence => true,
                              :uniqueness => true,
                              :length => { :maximum => 30 }
  validates :label, :presence => true
  validates :input_type, :presence => true, :inclusion => { :in => INPUT_TYPE }

  default_scope { order('position') } 

  scope :by_code,   lambda {|code|where(["attribute_code=?", code])}

  def initialize(attributes=nil, *args)
    super
    if new_record?
      # set default values for new records only
      initialized = (attributes || {}).stringify_keys
      if !initialized.key?('is_system_entity')
        self.is_system_entity = false
      end            
    end
  end

  # => Dynamic methods for input types
  INPUT_TYPE.each do |type|
    define_method "#{type}?" do
      self.input_type == type
    end
  end

  # => Dynamically defining these custom finder methods
  class << self
    INPUT_TYPE.each do |type|
      define_method "#{type}" do
        where(["input_type=?", type])
      end
    end
  end  
end
