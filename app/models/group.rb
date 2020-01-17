class Group < ActiveRecord::Base
  resourcify
  attr_accessible :name, :parent, :priority, :rest_reg_no
  
  has_many :subgroups, :class_name => "Group", :foreign_key => :parent, :dependent => :destroy
  has_many :users
end
