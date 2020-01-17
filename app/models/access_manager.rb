class AccessManager < ActiveRecord::Base
  attr_accessible :controller_actions, :controller_alias, :controller_name
end
