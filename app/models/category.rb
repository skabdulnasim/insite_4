class Category < ActiveRecord::Base
  resourcify

  #acts_as_tree :order => "name"

  #@cat_set = []

  attr_accessible :name, :description,:catagory_image, :parent, :code
  validates :name, :presence => true
  # validates :code, :uniqueness => true
  
  has_many :subcategories, :class_name => "Category", :foreign_key => :parent
  #has_one :parent, :class_name => "Category", :primary_key => :parent, :foreign_key => :id
  has_many :products
  
  scope :get_cat_name, lambda{|id|where("id = ?",id)}
  scope :get_parent_cat, lambda {|parent_id| where("id = ?",parent_id)}
  scope :get_root_categories, lambda { where(:parent => nil) }
  scope :set_parent_category, lambda {|parent_id| where("parent = ?",parent_id)}
  scope :by_category_ids, lambda{|id_list|where("id IN(?)",id_list)}
  def self.get_all_subcategories(cat_id)

    _categories = Category.where(:parent => cat_id)
    cat_set = []
  	#@cat_set.push cat_id.to_i
    cat_set.push cat_id.to_i
    
  	if _categories.present?
  	  _categories.each do |_category|
  	    #@cat_set.push _category[:id]
        cat_set.push _category[:id]
  	    if _category[:parent]
  	  	  Category.get_all_subcategories(_category[:id])
  	    end 
  	  end
  	end
  	return cat_set
  end
  def update_image
    self['image_original'] = self.image(:original)
    
    self.image.styles.each do |format|
      self["image_#{format[0].to_s}"] = self.image(format[0].to_s)
    end
    
  end
  def self.get_category_products(_cat_id)  
    _category=Category.find(_cat_id)
    _products = _category.products
    _child_categories = Category.where(:parent => _cat_id)
    if _child_categories.present?
      _child_categories.each do |cc|
        _child_products = get_category_products(cc.id)  
        _products = _products + _child_products
      end
    end
    return _products
  end 

  def self.category_csv_upload(kk)
    if kk[0][:parent].nil?
      new_category = Category.new
      new_category[:name] = kk[0][:name]
      # new_category[:description] = kk[0][:description]
      new_category.save
    else
      parent_category_id = Category.find_by_name(kk[0][:parent])
      new_category = Category.new
      new_category[:name] = kk[0][:name]
      new_category[:parent] = parent_category_id[:id]
      # new_category[:description] = kk[0][:description]
      new_category.save
    end
  end
end
