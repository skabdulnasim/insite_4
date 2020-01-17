class ResourceField < ActiveRecord::Base
  belongs_to :resource_type
  attr_accessible :field_type, :is_compareable, :is_sortable, :is_unique, :name, :required

  scope :required,      lambda{where(required: true)}
  scope :sortable,      lambda{where(is_sortable: true)}
  scope :unique,        lambda{where(is_unique: true)}
  scope :compareable,   lambda{where(is_compareable: true)}
  scope :others,        lambda{where('required = false AND is_sortable = false AND is_unique = false AND is_compareable = false')}
end
