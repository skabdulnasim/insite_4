class StoreRequisitionMetaController < ApplicationController
  # GET /store_requisition_meta
  # GET /store_requisition_meta.json
  load_and_authorize_resource
  def index
    @store_requisition_meta = StoreRequisitionMetum.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @store_requisition_meta }
    end
  end

  # GET /store_requisition_meta/1
  # GET /store_requisition_meta/1.json
  def show
    @store_requisition_metum = StoreRequisitionMetum.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @store_requisition_metum }
    end
  end

  # GET /store_requisition_meta/new
  # GET /store_requisition_meta/new.json
  def new
    @store_requisition_metum = StoreRequisitionMetum.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @store_requisition_metum }
    end
  end

  # GET /store_requisition_meta/1/edit
  def edit
    @store_requisition_metum = StoreRequisitionMetum.find(params[:id])
  end

  # POST /store_requisition_meta
  # POST /store_requisition_meta.json
  def create
    @store_requisition_metum = StoreRequisitionMetum.new(params[:store_requisition_metum])

    respond_to do |format|
      if @store_requisition_metum.save
        format.html { redirect_to @store_requisition_metum, notice: 'Store requisition metum was successfully created.' }
        format.json { render json: @store_requisition_metum, status: :created, location: @store_requisition_metum }
      else
        format.html { render action: "new" }
        format.json { render json: @store_requisition_metum.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /store_requisition_meta/1
  # PUT /store_requisition_meta/1.json
  def update
    @store_requisition_metum = StoreRequisitionMetum.find(params[:id])

    respond_to do |format|
      if @store_requisition_metum.update_attributes(params[:store_requisition_metum])
        format.html { redirect_to @store_requisition_metum, notice: 'Store requisition metum was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @store_requisition_metum.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /store_requisition_meta/1
  # DELETE /store_requisition_meta/1.json
  def destroy
    @store_requisition_metum = StoreRequisitionMetum.find(params[:id])
    @store_requisition_metum.destroy

    respond_to do |format|
      format.html { redirect_to store_requisition_meta_url }
      format.json { head :no_content }
    end
  end
end
