class ResourceState < ActiveRecord::Base
  attr_accessible :color_code, :name, :state_priority, :trash
  has_many :resources
end
