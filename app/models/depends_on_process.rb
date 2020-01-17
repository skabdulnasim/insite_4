class DependsOnProcess < ActiveRecord::Base
  attr_accessible :process_composition_id, :process_id

  #Model Relations
  belongs_to :production_process, :foreign_key => :process_id
end
