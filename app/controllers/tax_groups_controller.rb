class TaxGroupsController < ApplicationController
  load_and_authorize_resource

  layout "material"
  before_filter :set_module_details
  # GET /tax_groups
  # GET /tax_groups.json
  def index
    @tax_groups = TaxGroup.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @tax_groups }
    end
  end

  # GET /tax_groups/1
  # GET /tax_groups/1.json
  def show
    @tax_group = TaxGroup.find(params[:id])
    @tax_classes = TaxClass.where(:tax_type => "simple")

    @save_tax_groups_tax_classes_id = Array.new
    @tax_group.tax_classes.uniq.each do |tax_class|
      @save_tax_groups_tax_classes_id.push tax_class[:id]
    end


    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @tax_group }
    end
  end

  # GET /tax_groups/new
  # GET /tax_groups/new.json
  def new
    @tax_group = TaxGroup.new
    @owner_will_crud_menu = AppConfiguration.get_config_value('owner_will_crud_menu')
    @units = Unit.all

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @tax_group }
      format.js
    end
  end

  # GET /tax_groups/1/edit
  def edit
    @tax_group = TaxGroup.find(params[:id])
    @owner_will_crud_menu = AppConfiguration.get_config_value('owner_will_crud_menu')
    @units = Unit.all
  end

  # POST /tax_groups
  # POST /tax_groups.json
  def create
    @tax_group = TaxGroup.new(params[:tax_group])
    
    respond_to do |format|
      if @tax_group.save
        format.html { redirect_to sections_path, notice: 'Tax group was successfully created.' }
        format.json { render json: @tax_group, status: :created, location: @tax_group }
        format.js
      else
        format.html { render action: "new" }
        format.json { render json: @tax_group.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /tax_groups/1
  # PUT /tax_groups/1.json
  def update
    params[:tax_group][:tax_class_ids] ||= []
    @tax_group = TaxGroup.find(params[:id])
    respond_to do |format|
      if @tax_group.update_attributes(params[:tax_group])
        format.html { redirect_to @tax_group, notice: 'Tax group was successfully updated.' }
        format.json { head :no_content }
        format.js
      else
        format.html { render action: "edit" }
        format.json { render json: @tax_group.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /tax_groups/1
  # DELETE /tax_groups/1.json
  def destroy
    @tax_group = TaxGroup.find(params[:id])
    @tax_group.destroy

    respond_to do |format|
      format.html { redirect_to tax_groups_url }
      format.json { head :no_content }
      format.js
    end
  end

  # DELETE /tax_groups/1
  # DELETE /tax_groups/1.json
  def save_tax_groups_tax_classes
    ActiveRecord::Base.connection.execute("DELETE from tax_classes_tax_groups WHERE tax_group_id=#{params[:tax_group]};")
    if params[:tax_classes].present?
      params[:tax_classes].each do |tax_class|
        _tax_class = TaxClass.find(tax_class)
        _tax_group = TaxGroup.find(params[:tax_group])
        _tax_group.tax_classes << _tax_class
      end
    end
    kk = TaxGroup.save_total_amnt(params[:tax_group]) 
    respond_to do |format|
      format.html { redirect_to sections_path }
      format.json { head :no_content }
    end
  end
  private

  def set_module_details
    @module_id = "tax_groups"
    @module_title = "Tax Groups"
  end
end
