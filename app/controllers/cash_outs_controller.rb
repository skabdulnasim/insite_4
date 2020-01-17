class CashOutsController < ApplicationController
  # GET /cash_outs
  # GET /cash_outs.json
  before_filter :set_timerange, only: [:new]
  def index
    @cash_outs = CashOut.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @cash_outs }
    end
  end

  # GET /cash_outs/1
  # GET /cash_outs/1.json
  def show
    @cash_out = CashOut.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @cash_out }
    end
  end

  # GET /cash_outs/new
  # GET /cash_outs/new.json
  def new
    @cash_out = CashOut.new
    @denomination = Denomination.all
    @cash_out_descriptions = @cash_out.cash_out_descriptions.build


    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @cash_out }
    end
  end

  # GET /cash_outs/1/edit
  def edit
    @cash_out = CashOut.find(params[:id])
  end

  # POST /cash_outs
  # POST /cash_outs.json
  def create
    @cash_out = CashOut.new(params[:cash_out])
    puts @cash_out
    puts @cash_out.inspect

    
    # puts @cash_out.inspect
    respond_to do |format|
      if @cash_out.save
        
        format.html { redirect_to cash_handlings_path, notice: 'Cash out was successfully created.' }
        format.json { render json: @cash_out, status: :created, location: @cash_out }
      else
        format.html { render action: "new" }
        format.json { render json: @cash_out.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /cash_outs/1
  # PATCH/PUT /cash_outs/1.json
  def update
    @cash_out = CashOut.find(params[:id])

    respond_to do |format|
      if @cash_out.update_attributes(cash_out_params)
        format.html { redirect_to @cash_out, notice: 'Cash out was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @cash_out.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /cash_outs/1
  # DELETE /cash_outs/1.json
  def destroy
    @cash_out = CashOut.find(params[:id])
    @cash_out.destroy

    respond_to do |format|
      format.html { redirect_to cash_outs_url }
      format.json { head :no_content }
    end
  end

  private

    # Use this method to whitelist the permissible parameters. Example:
    # params.require(:person).permit(:name, :age)
    # Also, you can specialize this method with per-user checking of permissible attributes.
    def cash_out_params
      params.require(:cash_out).permit(:amount,:reason,:user_id,:unit_id,:device_id)
    end
end
