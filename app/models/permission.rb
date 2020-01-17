class Permission < ActiveRecord::Base
  # Attribute macros
  attr_accessible :subject_class, :action, :description, :permission_group_id

  # Association macros
  belongs_to :permission_group
  
  scope :by_class, lambda { |subject_class| where("subject_class=(?)", subject_class)  }
end
