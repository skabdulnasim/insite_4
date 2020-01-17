class MasterModel < ActiveRecord::Base
  attr_accessible :name, :status
  has_many :model_actions
end
