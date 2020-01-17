class ProductSize < ActiveRecord::Base
  attr_accessible :product_id, :size_id, :size_name, :status, :product_size_images_attributes

  belongs_to :product
  belongs_to :size
  has_many :product_size_images

  before_validation :set_attributes

  accepts_nested_attributes_for :product_size_images, allow_destroy: true
  #Model scope
  scope :by_product_id,  lambda {|product_id|where(["product_id=?", product_id])}
  scope :enabled, lambda{where(["status=?",0])}
  private

  def set_attributes
    self.size_name = self.size.name
  end

  def self.import_product_size_image(file)
    imported_product_size_images =Array.new
    data_errors = Array.new
    CSV.foreach(file.path, headers: true) do |row|
      product = Product.find_by_name(row["Product"])
      size = Size.find_by_name(row["Size"])
      if product.present? && size.present?
        product_size = ProductSize.find_by_product_id_and_size_id(product.id,size.id)
        if product_size.present?
          if product_size.product_size_images.count < 6 && row["Image"].present?
            product_size.attributes = {:product_size_images_attributes=>{"#{DateTime.now.strftime('%Q')}"=>{:image=>URI.parse(row["Image"])}}}
            imported_product_size_images.push product_size
          end
        end
      end
    end
        
    if imported_product_size_images.map(&:valid?).all?
      imported_product_size_images.each(&:save!)
      true
    else
      imported_product_size_images.each_with_index do |product_size, index|
        unless product_size.valid?
          errors_messages = self.error_messages_for(product_size)
          data_errors.push("Row #{index+2}: #{errors_messages}")
        end
      end
      error_str = data_errors.map { |e| e }.join(', ')
      raise "Data of #{data_errors.size} row(s) prevented the form being saved. #{error_str}"
    end
  end

end
