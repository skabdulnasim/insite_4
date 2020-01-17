class CashInsController < ApplicationController
  # GET /cash_ins
  # GET /cash_ins.json
  before_filter :set_timerange, only: [:new]
  def index
    @cash_ins = CashIn.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @cash_ins }
    end
  end

  # GET /cash_ins/1
  # GET /cash_ins/1.json
  def show
    @cash_in = CashIn.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @cash_in }
    end
  end

  # GET /cash_ins/new
  # GET /cash_ins/new.json
  def new
    @cash_in = CashIn.new
    @denomination = Denomination.all
    @cash_in_descriptions = @cash_in.cash_in_descriptions.build

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @cash_in }
    end
  end

  # GET /cash_ins/1/edit
  def edit
    @cash_in = CashIn.find(params[:id])
  end

  # POST /cash_ins
  # POST /cash_ins.json
  def create
    # @cash_in = CashIn.new(cash_in_params)
    @cash_in = CashIn.new(params[:cash_in])
    
    respond_to do |format|
      if @cash_in.save
        format.html { redirect_to cash_handlings_path, notice: 'Cash in was successfully created.' }
        format.json { render json: @cash_in, status: :created, location: @cash_in }
      else
        format.html { render action: "new" }
        format.json { render json: @cash_in.errors, status: :unprocessable_entity }
      end
    end
  end


  # PATCH/PUT /cash_ins/1
  # PATCH/PUT /cash_ins/1.json
  def update
    @cash_in = CashIn.find(params[:id])

    respond_to do |format|
      if @cash_in.update_attributes(cash_in_params)
        format.html { redirect_to @cash_in, notice: 'Cash in was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @cash_in.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /cash_ins/1
  # DELETE /cash_ins/1.json
  def destroy
    @cash_in = CashIn.find(params[:id])
    @cash_in.destroy

    respond_to do |format|
      format.html { redirect_to cash_ins_url }
      format.json { head :no_content }
    end
  end

  private

    # Use this method to whitelist the permissible parameters. Example:
    # params.require(:person).permit(:name, :age)
    # Also, you can specialize this method with per-user checking of permissible attributes.
    def cash_in_params
      params.require(:cash_in).permit(:amount,:reason,:user_id,:unit_id,:device_id,:bill_serial_no)
    end
end
