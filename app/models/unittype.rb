class Unittype < ActiveRecord::Base
  acts_as_paranoid
  acts_as_list

  attr_accessible :unit_type_name, :unit_type_priority, :store_creatability, :position

  has_many :units, dependent: :restrict_with_exception


  # The :dependent option expects either :destroy, :delete_all, :nullify or :restrict (:restrict_with_exception)


  after_create :update_priority

  validates :unit_type_name, :presence => true

  scope :by_less_position, lambda {|position|where(["position > (?)", position])}
  scope :by_same_and_less_position, lambda {|position|where(["position >= (?)", position])}

  def update_priority
    update_attribute(:unit_type_priority, self.position)
  end

  def self.fetch_units_from_unittype(unittype_id)
    type_prio_id = Unittype.find(unittype_id).unit_type_priority
    req_type_prio = Unittype.where(:unit_type_priority => type_prio_id).select('id')
    ids = Array.new
    req_type_prio.each do |r|
     ids.push(r.id)
    end
    type_info = Unit.where(:unittype_id => ids)
    return type_info
  end
end
