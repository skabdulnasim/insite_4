class ResourceType < ActiveRecord::Base
  attr_accessible :name, :fields_attributes, :section_id, :availability_type
  has_many :fields, class_name: "ResourceField"
  has_many :resources
  belongs_to :section
  accepts_nested_attributes_for :fields, allow_destroy: true

  INPUT_TYPE = %w[text_field check_box]

  scope :by_resource_type_name,    lambda { |name| where(["lower(name) = ?",name.downcase]) }
  scope :by_section_id,    lambda { |section_id| where(["section_id = ?",section_id]) }
  
end
