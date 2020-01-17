class TermAttribute < ActiveRecord::Base
  attr_accessible :name, :attribute_id
  scope :get_terms, lambda {|id| where(["attribute_id = ?", id])}
  # belongs_to :attribute # rails 4 migration comment
  belongs_to :p_attribute, class_name: "Attribute", foreign_key: "attribute_id"
end
