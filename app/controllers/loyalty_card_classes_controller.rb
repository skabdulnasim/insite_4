class LoyaltyCardClassesController < ApplicationController
  layout "material"
  def index
    @loyalty_card_classes = LoyaltyCardClass.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @loyalty_card_classes }
    end
  end

  # GET /loyalty_card_classes/1
  # GET /loyalty_card_classes/1.json
  def show
    @loyalty_card_class = LoyaltyCardClass.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @loyalty_card_class }
    end
  end

  # GET /loyalty_card_classes/new
  # GET /loyalty_card_classes/new.json
  def new
    @loyalty_card_class = LoyaltyCardClass.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @loyalty_card_class }
    end
  end

  # GET /loyalty_card_classes/1/edit
  def edit
    @loyalty_card_class = LoyaltyCardClass.find(params[:id])
  end

  # POST /loyalty_card_classes
  # POST /loyalty_card_classes.json
  def create
    begin
      @loyalty_card_class = LoyaltyCardClass.new(loyalty_card_class_params)
      @loyalty_card_class.save
      redirect_to loyalty_card_classes_path, notice: 'Loyalty card class was successfully created.'
      # respond_to do |format|
      #   if 
      #     format.html {  }
      #     format.json { render json: @loyalty_card_class, status: :created, location: @loyalty_card_class }
      #   else
      #     format.html { render action: "new" }
      #     format.json { render json: @loyalty_card_class.errors, status: :unprocessable_entity }
      #   end
      # end
    rescue Exception => @error
      redirect_to :back, alert: @error.message.to_s
      @log = Rscratch::Exception.log(@error,request)
    end
    
  end

  # PATCH/PUT /loyalty_card_classes/1
  # PATCH/PUT /loyalty_card_classes/1.json
  def update
    @loyalty_card_class = LoyaltyCardClass.find(params[:id])

    respond_to do |format|
      if @loyalty_card_class.update_attributes(loyalty_card_class_params)
        format.html { redirect_to loyalty_card_classes_path, notice: 'Loyalty card class was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @loyalty_card_class.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /loyalty_card_classes/1
  # DELETE /loyalty_card_classes/1.json
  def destroy
    @loyalty_card_class = LoyaltyCardClass.find(params[:id])
    @loyalty_card_class.destroy

    respond_to do |format|
      format.html { redirect_to loyalty_card_classes_url }
      format.json { head :no_content }
    end
  end

  private

    # Use this method to whitelist the permissible parameters. Example:
    # params.require(:person).permit(:name, :age)
    # Also, you can specialize this method with per-user checking of permissible attributes.
    def loyalty_card_class_params
      params.require(:loyalty_card_class).permit(:name, :enrollment_rule=>[:amount,:point,:validity,:refundable],:recharge_rule=>[:amount,:point,:validity,:refundable],:reward_rule=>[:amount,:point,:validity,:refundable],:debit_rule=>[:amount,:point])
    end
end
