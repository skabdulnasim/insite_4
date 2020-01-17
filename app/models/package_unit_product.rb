class PackageUnitProduct < ActiveRecord::Base
  attr_accessible :package_unit_id, :product_id, :quantity, :sku, :package_id

  # Model Relations
  belongs_to :package_unit
  belongs_to :product
  belongs_to :package

  # Model Callbacks
  after_create :set_package

  # Model Scopes
  scope :set_package_unit_in, lambda {|package_unit_ids| where (["package_unit_id in (?)", package_unit_ids])}
  scope :by_product, lambda {|product_id| where (["product_id = ?", product_id])}
  scope :by_package_unit, lambda {|package_unit_id| where (["package_unit_id = ?", package_unit_id])}
  scope :by_package, lambda {|package_id| where (["package_id = ?", package_id])}

  def set_package
  	self.update_attributes(:package_id=>self.package_unit.package_id)
  end

end