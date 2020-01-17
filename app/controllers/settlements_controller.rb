include SettlementsHelper
class SettlementsController < ApplicationController
  load_and_authorize_resource :except => [:create]
  
  # GET /settlements
  # GET /settlements.json
  def index
    @settlements = Settlement.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @settlements }
    end
  end

  # GET /settlements/1
  # GET /settlements/1.json
  def show
    @settlement = Settlement.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @settlement }
    end
  end

  # GET /settlements/new
  # GET /settlements/new.json
  def new
    @settlement = Settlement.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @settlement }
    end
  end

  # GET /settlements/1/edit
  def edit
    @settlement = Settlement.find(params[:id])
  end

  #>>>>>>>>>>>>>>>>> APIPie START >>>>>>>>>>>>>>>>>#
  create_settlement_apipie_doc #SettlementsHelper
  #<<<<<<<<<<<<<<<<< API-PIE END <<<<<<<<<<<<<<<<<<#    
  # POST /settlements
  # POST /settlements.json
  def create
    begin
      ActiveRecord::Base.transaction do
        @settlement = Settlement.new(settlement_params)
        if @settlement.save
          respond_to do |format|
            format.json { render json: { :success => 'Bill is setteled successfully.' }, status: :created }
          end          
        else
          raise error_messages_for(@settlement)
        end        
      end
    rescue Exception => e
      Rscratch::Exception.log e,request
      respond_to do |format|
        format.json { render json: {:error => e.message.to_s} }
      end
    end
  end

  # PUT /settlements/1
  # PUT /settlements/1.json
  def update
    @settlement = Settlement.find(params[:id])

    respond_to do |format|
      if @settlement.update_attributes(params[:settlement])
        format.html { redirect_to @settlement, notice: 'Settlement was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @settlement.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /settlements/1
  # DELETE /settlements/1.json
  def destroy
    @settlement = Settlement.find(params[:id])
    @settlement.destroy

    respond_to do |format|
      format.html { redirect_to settlements_url }
      format.json { head :no_content }
    end
  end
  
  private
  def create_payment_mode(payment)
    # payment["payment_mode"].capitalize.classify.constantize.create(payment["data"])
    payment["payment_mode"].camelize.classify.constantize.create(payment["data"])
  end

  def settlement_params
    params[:settlement] = JSON.parse(params[:settlement])
    params[:payments]   = JSON.parse(params[:payments])
    {
      "device_id"     => params[:device_id],
      "bill_id"       => params[:settlement][:bill_id],
      "tips"          => params[:settlement][:tips],
      "client_id"     => params[:settlement][:client_id],
      "client_type"   => params[:settlement][:client_type],
      "split_bill_id" => params[:settlement][:split_bill_id],
      "recorded_at"   => params[:settlement][:recorded_at] || Time.now.utc,
      "payments_attributes" => params[:payments].map { |p| {"paymentmode_type" => p[:payment_mode], "paymentmode_attributes" => p[:data]} }
    }
  end  
end
