class ProductionProcess < ActiveRecord::Base
  attr_accessible :category_id, :cost, :local_name, :name, :short_name, :is_trashed, :process_image

  has_attached_file :process_image, :styles => { :medium => "250x250>", :thumb => "60x60>" }, :default_url => "/images/:style/missing.png"
  validates_attachment_content_type :process_image, :content_type => /\Aimage\/.*\Z/
  
  belongs_to :category
  belongs_to :physical_type

  has_many :conjugated_units

  validates :name,              :presence => true, 
                                :uniqueness => true
  validates :category_id, 			:presence => true

  scope :by_category_id, lambda {|cat_id| where(["category_id=?", cat_id])}

  def self.filter_by_string(searcing_text)
    if searcing_text.present?
      where("lower(production_processes.name) LIKE ?", "%#{searcing_text.downcase}%")
    else
      all
    end    
  end
end