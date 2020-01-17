class CustomerQueueStatesController < ApplicationController
  # GET /customer_queue_states
  # GET /customer_queue_states.json
  def index
    @customer_queue_states = CustomerQueueState.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @customer_queue_states }
    end
  end

  # GET /customer_queue_states/1
  # GET /customer_queue_states/1.json
  def show
    @customer_queue_state = CustomerQueueState.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @customer_queue_state }
    end
  end

  # GET /customer_queue_states/new
  # GET /customer_queue_states/new.json
  def new
    @customer_queue_state = CustomerQueueState.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @customer_queue_state }
    end
  end

  # GET /customer_queue_states/1/edit
  def edit
    @customer_queue_state = CustomerQueueState.find(params[:id])
  end

  # POST /customer_queue_states
  # POST /customer_queue_states.json
  def create
    @customer_queue_state = CustomerQueueState.new(customer_queue_state_params)

    respond_to do |format|
      if @customer_queue_state.save
        format.html { redirect_to @customer_queue_state, notice: 'Customer queue state was successfully created.' }
        format.json { render json: @customer_queue_state, status: :created, location: @customer_queue_state }
      else
        format.html { render action: "new" }
        format.json { render json: @customer_queue_state.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /customer_queue_states/1
  # PATCH/PUT /customer_queue_states/1.json
  def update
    @customer_queue_state = CustomerQueueState.find(params[:id])

    respond_to do |format|
      if @customer_queue_state.update_attributes(customer_queue_state_params)
        format.html { redirect_to @customer_queue_state, notice: 'Customer queue state was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @customer_queue_state.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /customer_queue_states/1
  # DELETE /customer_queue_states/1.json
  def destroy
    @customer_queue_state = CustomerQueueState.find(params[:id])
    @customer_queue_state.destroy

    respond_to do |format|
      format.html { redirect_to customer_queue_states_url }
      format.json { head :no_content }
    end
  end

  private

    # Use this method to whitelist the permissible parameters. Example:
    # params.require(:person).permit(:name, :age)
    # Also, you can specialize this method with per-user checking of permissible attributes.
    def customer_queue_state_params
      params.require(:customer_queue_state).permit(:color_code, :name, :trash)
    end
end
