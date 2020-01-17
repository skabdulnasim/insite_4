
class CustomerStatesController < ApplicationController
 
  # GET /customer_states
  # GET /customer_states.json
  def index
    @customer_states = CustomerState.all
    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @customer_states }
    end
  end

  # GET /customer_states/1
  # GET /customer_states/1.json
  def show
    @customer_state = CustomerState.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @customer_state }
    end
  end

  # GET /customer_states/new
  # GET /customer_states/new.json
  def new
    @customer_state = CustomerState.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @customer_state }
    end
  end

  # GET /customer_states/1/edit
  def edit
    @customer_state = CustomerState.find(params[:id])
  end

  # POST /customer_states
  # POST /customer_states.json
  def create
    @customer_state = CustomerState.new(customer_state_params)

    respond_to do |format|
      if @customer_state.save
        format.html { redirect_to customer_states_path, notice: 'Customer state was successfully created.' }
        format.json { render json: customer_states_path, status: :created, location: @customer_state }
      else
        format.html { render action: "new" }
        format.json { render json: @customer_state.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /customer_states/1
  # PATCH/PUT /customer_states/1.json
  def update
    @customer_state = CustomerState.find(params[:id])

    respond_to do |format|
      if @customer_state.update_attributes(customer_state_params)
        format.html { redirect_to @customer_state, notice: 'Customer state was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @customer_state.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /customer_states/1
  # DELETE /customer_states/1.json
  def destroy
    @customer_state = CustomerState.find(params[:id])
    @customer_state.destroy

    respond_to do |format|
      format.html { redirect_to customer_states_url }
      format.json { head :no_content }
    end
  end
  def update_status
    puts "params #{params}"
    customer_state = CustomerState.find(params[:id])
    customer_state.update_attribute(:status,params[:status])
    respond_to do |format|
      format.json { render json: customer_state }
    end
  end

  private
  def customer_state_params
    params.require(:customer_state).permit(:name,:icon,:color,:status)
  end
end
