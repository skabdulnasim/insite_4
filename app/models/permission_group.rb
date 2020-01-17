class PermissionGroup < ActiveRecord::Base
  acts_as_list

  # Attribute macros
  attr_accessible :name, :position
  
  # Association macros
  has_many :permissions
end
