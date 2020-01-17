class Section < ActiveRecord::Base
  belongs_to :unit
  has_many :tables,->{where(:is_trashed => false, :status => 'enabled')},:class_name => 'Table'
  has_many :disabled_tables, ->{where(:is_trashed => false, :status => 'disabled')},:class_name => 'Table'
  has_many :tax_groups
  has_many :menu_cards, ->{where(:mode => 1)},:class_name => 'MenuCard'
  has_many :printers, as: :assignable
  has_many :orders, as: :deliverable
  has_many :thirdparty_configurations
  has_one :table_reservation
  belongs_to :additional_information, :class_name => "Unit"
  has_many :resources, ->{where(:status => 'enabled')},:class_name => 'Resource'
  has_and_belongs_to_many :tax_classes
  has_many :options
  has_many :addons_groups
  
  attr_accessible :description, :name, :unit_id, :additional_tax, :section_type, :bill_header, :bill_footer,:master_section_id, :thirdparty_configurations_attributes

  accepts_nested_attributes_for :thirdparty_configurations, allow_destroy: true

  # => Generate status log after creation of order
  after_save  :cal_and_save_additional_tax

  scope :unit_sections, lambda {|unit_id|where(["unit_id=?", unit_id])}
  scope :unit_section_by_master_section, lambda {|unit_id,master_section_id|where(["unit_id=? AND master_section_id=?", unit_id,master_section_id])}
  scope :dinein_section, lambda{ where(["section_type = ?",'dinein']) }
  scope :by_section_type, lambda {|section_type| where(["section_type = ?",section_type])}
 
  scope :where_id_in,         lambda {|ids|where(["id in (?)", ids])}
  scope :unit_ids_in,         lambda {|unit_ids|where(["unit_id in (?)", unit_ids])}
  scope :by_section_name,    lambda { |section_name| where(["lower(name) = ?",section_name.downcase]) }

  def self.save_tax_classes(section, tax_classes)
    self.clear_tax_classes(section.id)
    tax_classes.each do |tax_class|
      _tax_class = TaxClass.find(tax_class)
      section.tax_classes << _tax_class
    end
  end

  def self.clear_tax_classes(section_id)
    if section_id.present?
      ActiveRecord::Base.connection.execute("DELETE from sections_tax_classes WHERE section_id=#{section_id};")
    end
  end

  private

  def cal_and_save_additional_tax
    sum = 0
    self.tax_classes.uniq.each do |tax_class|
      sum = sum.to_f + tax_class[:ammount].to_f
    end
    self.update_column(:additional_tax, sum)
  end 
end
