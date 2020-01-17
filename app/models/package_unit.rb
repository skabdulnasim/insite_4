class PackageUnit < ActiveRecord::Base
  attr_accessible :package_id, :parent, :unit_name

  #Model Relations
  belongs_to :package
  has_many :sub_package_units, :class_name => "PackageUnit", :foreign_key => :parent, :dependent => :destroy
  has_many :package_unit_products, :dependent => :destroy

  #Model Scopes
  scope :get_root_units, lambda { where(:parent => nil) }
  scope :by_package, lambda {|package_id| where (["package_id = ?", package_id])}
end