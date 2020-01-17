module DealMaker
  class Deal < ActiveRecord::Base
    attr_accessible :description, :end_time, :name, :start_time, :status
  end
end
