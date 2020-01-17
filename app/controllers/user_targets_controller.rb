class UserTargetsController < ApplicationController
  include SmartListing::Helper::ControllerExtensions
  helper  SmartListing::Helper
  # GET /user_targets
  # GET /user_targets.json
  def index
    # @user_targets = UserTarget.all
    @can_initiate_new_target = false
    current_user_role = current_user.users_role.role.name
    config_key = "initiate_target_by_#{current_user_role}"
    config_status = AppConfiguration.set_key(config_key).first
    if config_status.present?
      if config_status.config_value == "enabled"
        @can_initiate_new_target = true
      end
    end
    @user_targets = current_user.child_user_targets
    @current_user_target= current_user.own_targets.includes(:child_targets)
    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @user_targets }
    end
  end

  # GET /user_targets/1
  # GET /user_targets/1.json
  def show
    @user_target = UserTarget.find(params[:id])
    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @user_target }
    end
  end

  # GET /user_targets/new
  # GET /user_targets/new.json
  def new
    @target_type = params["target_type"]
    @user_target = UserTarget.new
    if @target_type == "by_product"
      if params[:target_id].present?
        @user_target = UserTarget.find(params[:target_id])
        @child_targets = @user_target.child_targets
        puts "child targtes present" if @child_targets.present?
        @child_targets.each do |child_target|
          p child_target
        end 
        @products = @user_target.user_target_products
        smart_listing_create :user_target_products,@products, :partial => "user_targets/user_target_products_smart_list"
      else
        @products = Product.order("name ASC")
        @products = @products.filter_by_string(params[:product_search]) if params[:product_search].present?
        smart_listing_create :product_list,@products,:partial => "user_targets/products_smart_list",page_sizes:[10]
      end
    end
    respond_to do |format|
      format.js
      format.html # new.html.erb
      format.json { render json: @user_target }
    end
  end

  # GET /user_targets/1/edit
  def edit
    @user_target = UserTarget.find(params[:id])
  end

  # POST /user_targets
  # POST /user_targets.json
  def create
    begin
      if params[:target_type] == "by_amount"
        ActiveRecord::Base.transaction do # Protective transaction block
          raise 'Nothing selected for setting new target.' unless !params[:checked_child_users].blank? or !params[:checked_user_resources].blank?
          if params[:checked_child_users].present?
            puts "check user present"
            params[:checked_child_users].each do |cu|
              puts cu
              if params["target_id_#{cu}"].empty?
                _user_target = UserTarget.new(params[:user_target])
              else
                _user_target = UserTarget.find(params["target_id_#{cu}"])
              end
              _user_target.parent_user_id = params["parent_user_#{cu}"]
              _user_target.child_user_id = cu
              _user_target.target_amount = params["target_amount_#{cu}"]
              _user_target.parent_target = params["parent_target_id_#{cu}"]
              if params[:user_target][:duration] == 'monthly'
                _user_target.from_date = Date.parse(params[:target_month]).beginning_of_month
                _user_target.to_date = Date.parse(params[:target_month]).end_of_month
              end
              _user_target.save
            end
          end
          if params[:checked_user_resources].present?

            params[:checked_user_resources].each do |c_u_r|
              if params["resource_target_id_#{c_u_r}"].empty?
                _resource_target = ResourceTarget.new
              else
                _resource_target = ResourceTarget.find(params["resource_target_id_#{c_u_r}"])
              end
              _resource_target.resource_id = c_u_r.split('_')[1]
              _resource_target.target_by = c_u_r.split('_')[0]
              _resource_target.target_amount = params["resource_target_amount_#{c_u_r}"]
              _resource_target.user_target_id = params["user_target_id_#{c_u_r}"]
              if params[:user_target][:duration] == 'monthly'
                _resource_target.from_date = Date.parse(params[:target_month]).beginning_of_month
                _resource_target.to_date = Date.parse(params[:target_month]).end_of_month
              else
                _resource_target.from_date = params[:user_target][:from_date]
                _resource_target.to_date = params[:user_target][:to_date]
              end
              _resource_target.target_type = params[:user_target][:target_type]
              _resource_target.duration = params[:user_target][:duration]
              _resource_target.save
            end
          end
        end
      else
        if params[:target_month].present?
          #for monthly target
          from_date = Date.parse(params[:target_month]).beginning_of_month
          to_date = Date.parse(params[:target_month]).end_of_month
          product_hash = params[:user_products].to_hash if params[:user_products].present?
          if params[:target_for] == "user"
            product_hash.each do |user,products|
              user_id = user.split("_").last.to_i
              user_target = UserTarget.find_by_child_user_id_and_parent_target(user_id,params[:parent_target_id])
              if user_target.present?
                user_target.user_target_products.destroy_all
                user_target.user_target_products.create(products)
              else
                user_target = UserTarget.create(:parent_user_id=>current_user.id,:child_user_id=>user_id,:duration=>"monthly",:target_type=>params[:target_type],:from_date=>from_date,:to_date=>to_date,:parent_target=>params[:parent_target_id])
                user_target.user_target_products.create(products)
              end
            end
          else
            if params[:target_for] == "resource"
              product_hash.each do |resource,products|
                resource_id = resource.split("_").last.to_i
                resource_target = ResourceTarget.set_resource(resource_id).by_user_target_id(params[:parent_target_id]).first
                if resource_target.present?
                  resource_target.user_target_products.destroy_all
                  resource_target.user_target_products.create(products)
                else
                  resource_target = ResourceTarget.create(:user_target_id=>params[:parent_target_id],:target_by=>current_user.id,:resource_id=>resource_id,:from_date=>from_date,:to_date=>to_date,:target_type=>params[:target_type])
                  resource_target.user_target_products.create(products)
                end
              end           
            end
          end
        end
      end
      respond_to do |format|
        format.html { redirect_to user_targets_path(:target_type=>params[:target_type]), notice: 'Target process initiated.' }
      end
    rescue Exception => e
      Rscratch::Exception.log e,request
      if params[:parent_target_id].present?
        redirect_to new_user_target_path(:target_type=>params[:target_type],:target_id=>params[:parent_target_id]), alert: e.message
      else
        redirect_to new_user_target_path(:target_type=>params[:target_type]), alert: e.message
      end
    end



    # @user_target = UserTarget.new(user_target_params)

    # respond_to do |format|
    #   if @user_target.save
    #     format.html { redirect_to @user_target, notice: 'User target was successfully created.' }
    #     format.json { render json: @user_target, status: :created, location: @user_target }
    #   else
    #     format.html { render action: "new" }
    #     format.json { render json: @user_target.errors, status: :unprocessable_entity }
    #   end
    # end
  end

  # PATCH/PUT /user_targets/1
  # PATCH/PUT /user_targets/1.json
  def update
    @user_target = UserTarget.find(params[:id])

    respond_to do |format|
      if @user_target.update_attributes(user_target_params)
        format.html { redirect_to @user_target, notice: 'User target was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @user_target.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /user_targets/1
  # DELETE /user_targets/1.json
  def destroy
    @user_target = UserTarget.find(params[:id])
    @user_target.destroy

    respond_to do |format|
      format.html { redirect_to user_targets_url }
      format.json { head :no_content }
    end
  end

  private

    # Use this method to whitelist the permissible parameters. Example:
    # params.require(:person).permit(:name, :age)
    # Also, you can specialize this method with per-user checking of permissible attributes.
    def user_target_params
      params.require(:user_target).permit(:child_user_id, :duration, :from_date, :is_approved, :parent_user_id, :rejection_reason, :target_amount, :target_type, :to_date)
    end
end
