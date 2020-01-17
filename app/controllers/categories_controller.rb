class CategoriesController < ApplicationController
  load_and_authorize_resource

  require 'smarter_csv'

  layout "material"

  before_filter :set_module_details

  # GET /categories
  # GET /categories.json
  def index
    @category = Category.new
    @categories = Category.all.includes(:subcategories)
    @root_categories = Category.get_root_categories
    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @categories }
    end
  end

  # GET /categories/1
  # GET /categories/1.json
  def show
    @category = Category.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @category }
    end
  end

  # GET /categories/new
  # GET /categories/new.json
  def new
    @category = Category.new
    # @categories = Category.find(:all, :include => :subcategories) # rails 4 migration comment
    @categories = Category.all.includes(:subcategories)

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @category }
    end
  end

  # GET /categories/1/edit
  def edit
    @category = Category.find(params[:id])
    @categories = Category.all.includes(:subcategories)
  end

  # POST /categories
  # POST /categories.json
  def create
    @category = Category.new(params[:category])  
    respond_to do |format|
      if @category.save
        format.html { redirect_to categories_path, notice: 'Category was successfully created.' }
        format.json { render json: @category, status: :created, location: @category }
      else
        format.html { render action: "new" }
        format.json { render json: @category.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /categories/1
  # PUT /categories/1.json
  def update
    @category = Category.find(params[:id])

    respond_to do |format|
      if @category.update_attributes(params[:category])
        format.html { redirect_to categories_path, notice: 'Category was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @category.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /categories/1
  # DELETE /categories/1.json
  def destroy
    @category = Category.find(params[:id])
    
    # search subcategories of this cat and replace their parent cat id to current cat parent id
    @categories = Category.where(:parent => params[:id])
    @categories.each do |c|
      @sel_cat = Category.find(c.id)
      @sel_cat[:parent] = @category.parent
      @sel_cat.save
    end
    
    # search products under this cat and replace their cat id to null
    @products = Product.where(:category_id => params[:id])
    @products.each do |p|
      @sel_product = Product.find(p.id)
      @sel_product[:category_id] = ""
      @sel_product.save
    end
    @category.destroy
    respond_to do |format|
      format.html { redirect_to categories_path, notice: 'Category was successfully deleted.' }
      format.json { head :no_content }
    end
  end

  def bulk_upload
    ActiveRecord::Base.transaction do
      uploaded_file = params[:csv_file]
      file_name = uploaded_file.tempfile.to_path.to_s
      #puts uploaded_file.original_filename
      uploaded_file_type = uploaded_file.original_filename.split('.')
      raise "The format should be in csv" unless uploaded_file_type[1] == "csv"
        # Category.delete_all
        SmarterCSV.process(file_name) do |header|
          Category.category_csv_upload(header)
        end
        respond_to do |format|
          format.html { redirect_to new_category_path, notice: "The category was uploaded successfully." }
        end
   end
    rescue Exception => e
      Rscratch::Exception.log e,request
      respond_to do |format|
        format.html { redirect_to new_category_path, notice: e.message.to_s }
      end
  end
  private

  def set_module_details
    @module_id = "products"
    @module_title = "Products"
  end  
end
