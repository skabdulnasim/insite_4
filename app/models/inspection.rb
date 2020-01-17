class Inspection < ActiveRecord::Base
  attr_accessible :day, :discussion, :latitude, :longitude, :recorded_at, :resource_id, :user_id, :image, :title, :address_id, :purpose, :inspected_entity_type, :inspected_entity_id, :inspection_questions_attributes
  audited
  #Model Relations
  belongs_to :user
  belongs_to :resource
  has_many :inspection_questions
  belongs_to :inspected_entity, polymorphic: true
  #Model Validation

  has_attached_file :image, :styles => { :medium => "250x250>", :thumb => "60x60>" }, :default_url => "/images/:style/missing.png"
  validates_attachment_content_type :image, :content_type => /\Aimage\/.*\Z/
  accepts_nested_attributes_for :inspection_questions
  def initialize(attributes=nil, *args)
    super 
    if new_record?
      initialized = (attributes || {}).stringify_keys
      if initialized.key?('user_id')
        user = User.find(self.user_id)
        self.unit_id = user.unit_id
      end
      if initialized.key?('resource_id')
        self.inspected_entity_id = self.resource_id
        self.inspected_entity_type = 'Resource'
      end  
      if initialized.key?('inspected_entity_type')
        self.inspected_entity_type = self.inspected_entity_type.capitalize
      end  
      if !initialized.key?('recorded_at')
        self.recorded_at = Time.now.utc
      else
        self.recorded_at = self.recorded_at.utc
      end
    end
  end

  #Model Callback

  #Model Scopres
  scope :by_resource, lambda{|resource_id| where(["resource_id= ?",resource_id])}
  scope :by_user,     lambda{|user_id| where(["user_id= ?",user_id])}
  scope :by_day,      lambda{|day| where(["day= ?",day])}
  scope :by_unit,     lambda{|unit_id| where(["inspections.unit_id=?",unit_id])}
  scope :by_unit_list, lambda{|unit_arr| where(["inspections.unit_id in(?)",unit_arr])}
  scope :vendor_inspection, lambda{ where(["inspected_entity_type = ?",'Vendor']) }
  scope :set_inspected_entity_type, lambda {|inspected_entity_type|where(["inspected_entity_type=?",inspected_entity_type])}
  scope :set_user_in, lambda {|user_ids|where(["inspections.user_id in (?)", user_ids])}
  scope :by_date_range, lambda {|from_date,to_date|where(["created_at BETWEEN ? AND ?",from_date,to_date])}
end
