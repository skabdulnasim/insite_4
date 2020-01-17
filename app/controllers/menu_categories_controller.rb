class MenuCategoriesController < ApplicationController
  load_and_authorize_resource

  layout "material"

  before_filter :set_module_details

  #>>>>>>>>>>>>>>>>> APIPie START >>>>>>>>>>>>>>>>>#
  api :GET, '/menu_categories.json', "Get all menu card categories"
  param :user_id, String, :desc => "User ID", :required => false
  error :code => 401, :desc => "Unauthorized"
  description "Get all menu card categoriess of current outlet"
  formats ['json', 'html']
  #<<<<<<<<<<<<<<<<< API-PIE END <<<<<<<<<<<<<<<<<<#
  def index
    @current_user_id = get_current_user_id()
    @current_user_info = UserManagement::get_current_user(@current_user_id)
    @menu_categories = MenuCategory.order("sort_order asc").all
    @menu_category = MenuCategory.new
    # @categories = MenuCategory.order("sort_order asc").find(:all,:conditions => ['unit_id =?', @current_user_info.unit_id], :include => :submenucategories)
    @categories = MenuCategory.where(:unit_id => @current_user_info.unit_id).order("sort_order asc").includes(:submenucategories)

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @menu_categories.to_json(:include => :submenucategories) }
    end
  end

  # GET /menu_categories/1
  # GET /menu_categories/1.json
  def show
    @menu_category = MenuCategory.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @menu_category }
    end
  end

  # GET /menu_categories/new
  # GET /menu_categories/new.json
  def new
    @menu_category = MenuCategory.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @menu_category }
    end
  end

  # GET /menu_categories/1/edit
  def edit
    @menu_category = MenuCategory.find(params[:id])
  end

  # POST /menu_categories
  # POST /menu_categories.json
  def create
    @menu_category = MenuCategory.new(params[:menu_category])
    @menu_category[:unit_id] = current_user.unit_id
    respond_to do |format|
      if @menu_category.save
        format.html { redirect_to :back, notice: 'Menu category was successfully created.' }
        format.json { render json: @menu_category, status: :created, location: @menu_category }
      else
        format.html { render action: "new" }
        format.json { render json: @menu_category.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /menu_categories/1
  # PUT /menu_categories/1.json
  def update

    puts "params are : #{params}"
    @menu_category = MenuCategory.find(params[:id])
    @menu_category.update_attributes(menu_category_params)
    respond_to do |format|
      if @menu_category.update_attributes(params[:menu_category])
        format.html { redirect_to :back, notice: 'Menu category was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @menu_category.errors, status: :unprocessable_entity }
      end
    end
  end

  def import
    begin
      ActiveRecord::Base.transaction do
        MenuCategory.import(params[:file],params[:unit_id],params[:menu_card_id])
        redirect_to :back, notice: 'Menu categories successfully imported.'
      end      
    rescue Exception => e
      flash[:error] = e.message
      redirect_to :back
    end
  end

  # DELETE /menu_categories/1
  # DELETE /menu_categories/1.json
  def destroy
    @menu_category = MenuCategory.find(params[:id])
    @menu_category.destroy

    respond_to do |format|
      format.html { redirect_to :back }
      format.json { head :no_content }
    end
  end

  private
    def set_module_details
      @module_id = "menu_cards"
      @module_title = I18n.t(:calatog_title)
    end
    def menu_category_params
      params.require(:menu_category).permit(:name,:description,:image,:parent)
    end
end
