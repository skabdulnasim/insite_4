class PurchaseOrderMetaController < ApplicationController
  # GET /purchase_order_meta
  # GET /purchase_order_meta.json
  load_and_authorize_resource
  def index
    @purchase_order_meta = PurchaseOrderMetum.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @purchase_order_meta }
    end
  end

  # GET /purchase_order_meta/1
  # GET /purchase_order_meta/1.json
  def show
    @purchase_order_metum = PurchaseOrderMetum.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @purchase_order_metum }
    end
  end

  # GET /purchase_order_meta/new
  # GET /purchase_order_meta/new.json
  def new
    @purchase_order_metum = PurchaseOrderMetum.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @purchase_order_metum }
    end
  end

  # GET /purchase_order_meta/1/edit
  def edit
    @purchase_order_metum = PurchaseOrderMetum.find(params[:id])
  end

  # POST /purchase_order_meta
  # POST /purchase_order_meta.json
  def create
    @purchase_order_metum = PurchaseOrderMetum.new(params[:purchase_order_metum])

    respond_to do |format|
      if @purchase_order_metum.save
        format.html { redirect_to @purchase_order_metum, notice: 'Purchase order metum was successfully created.' }
        format.json { render json: @purchase_order_metum, status: :created, location: @purchase_order_metum }
      else
        format.html { render action: "new" }
        format.json { render json: @purchase_order_metum.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /purchase_order_meta/1
  # PUT /purchase_order_meta/1.json
  def update
    @purchase_order_metum = PurchaseOrderMetum.find(params[:id])

    respond_to do |format|
      if @purchase_order_metum.update_attributes(params[:purchase_order_metum])
        format.html { redirect_to @purchase_order_metum, notice: 'Purchase order metum was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @purchase_order_metum.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /purchase_order_meta/1
  # DELETE /purchase_order_meta/1.json
  def destroy
    @purchase_order_metum = PurchaseOrderMetum.find(params[:id])
    @purchase_order_metum.destroy

    respond_to do |format|
      format.html { redirect_to purchase_order_meta_url }
      format.json { head :no_content }
    end
  end
end
