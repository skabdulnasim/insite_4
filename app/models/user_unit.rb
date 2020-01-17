class UserUnit < ActiveRecord::Base
  belongs_to :user
  belongs_to :unit
  attr_accessible :user_id, :unit_id
end
