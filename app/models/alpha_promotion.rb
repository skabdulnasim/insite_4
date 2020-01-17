class AlphaPromotion < ActiveRecord::Base
  has_and_belongs_to_many :units
  attr_accessible :description, :promo_code, :promo_type, :promo_value, :status, :valid_from, :valid_till,:scope,:unit_ids, :promo_user, :count, :bill_amount, :max_discount, :image
  has_attached_file :image, :styles => { :medium => "250x250>", :thumb => "60x60>" }, :default_url => "/images/:style/missing.png"
  validates_attachment_content_type :image, :content_type => /\Aimage\/.*\Z/

  STATUS = %w(active inactive)
  TYPE = %w(by_percentage by_amount)
  PROMO_USER = %w(staff customer)
  
  # => Dynamic methods for promo statuses
  STATUS.each do |status|
    define_method "#{status}?" do
      self.status == status
    end
  end

  # => Dynamically defining these custom finder methods
  class << self
    STATUS.each do |status|
      define_method "#{status}" do
        where(["status=?", status])
      end
    end
  end

  validates :status, :presence => true, :inclusion => {:in => STATUS}

  scope :by_code, lambda {|promo_code|where(["promo_code=?", promo_code])}
  scope :by_unit_id, lambda {|unit_id| where(["unit_id = ?", unit_id])}
  scope :staff_promo, lambda{where(["promo_user=?",'staff'])}
  def self.check_promo_date_validity(current_date)
    where('? BETWEEN alpha_promotions.valid_from AND alpha_promotions.valid_till',current_date)
  end
end