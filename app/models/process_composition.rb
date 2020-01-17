class ProcessComposition < ActiveRecord::Base
  attr_accessible :product_id, :production_process_id, :duration, :production_process_name

  belongs_to :product
  belongs_to :production_process
  has_many :depends_on_processes

  validates :production_process_id,:presence => true
  validates :duration, :presence => true

  scope :by_product_id, lambda { |product_id| where(["product_id = ?",product_id]) }
  scope :get_process_composition, lambda { |product_id| where(["product_id = ?", product_id])}

  def production_process_name=(name)

  end
  def production_process_name
    self.production_process.name
  end
end