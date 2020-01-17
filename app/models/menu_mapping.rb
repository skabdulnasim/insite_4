class MenuMapping < ActiveRecord::Base
  attr_accessible :day_id, :menu_card_id, :merge_section_id, :section_id, :status, :unit_id

  #Model Relations
  belongs_to :day
  belongs_to :menu_card
  belongs_to :merge_section, :class_name => "Section"


  #Model Scope
  scope :by_day,  lambda {|day|where(["day_id=?", day])}
  scope :by_merge_section,  lambda {|merge_section_id|where(["merge_section_id=?", merge_section_id])}
  scope :active, lambda { where(["status = ?",'active']) }
  scope :by_unit_id, lambda { |unit_id| where( ["unit_id = ?", unit_id] ) }
end
