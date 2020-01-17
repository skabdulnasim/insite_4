class TaxGroup < ActiveRecord::Base
  attr_accessible :name, :section_id, :total_amnt, :fixed_amount, :tax_class_ids
  belongs_to :section
  has_and_belongs_to_many :tax_classes
  # has_and_belongs_to_many :active_tax_classes, :class_name => 'TaxClass', :conditions => { :is_trashed => false } rails 4 migration comment
  has_and_belongs_to_many :active_tax_classes, -> { where is_trashed: false }, :class_name => 'TaxClass'
  
  scope :by_amount, lambda { |amount| where(["total_amnt=?", amount])  }
  scope :by_section_ids, lambda{|section_ids|where("section_id in(?)",section_ids)}
  after_save  :save_amnt

  def self.save_total_amnt(tax_group_id)
    _tax_group = TaxGroup.find(tax_group_id)
    _percentage_amount = _tax_group.tax_classes.percentage.sum(:ammount)
    _fixed_amount = _tax_group.tax_classes.fixed_amount.sum(:ammount)
    _total_amount = 0
    _tax_group.tax_classes.each do |tax_class|
      _total_amount = _total_amount + tax_class[:ammount].to_f
    end
    _tax_group[:total_amnt] = _percentage_amount
    _tax_group[:fixed_amount] = _fixed_amount
    _tax_group.save
    return _tax_group
  end

  private 

  def save_amnt
    _percentage_amount = self.tax_classes.percentage.sum(:ammount)
    _fixed_amount = self.tax_classes.fixed_amount.sum(:ammount)
    self.update_column(:total_amnt, _percentage_amount)
    self.update_column(:fixed_amount, _fixed_amount)    
  end
end
