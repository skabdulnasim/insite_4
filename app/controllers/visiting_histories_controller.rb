class VisitingHistoriesController < ApplicationController
  # GET /visiting_histories
  # GET /visiting_histories.json
  def index
    @visiting_histories = VisitingHistory.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @visiting_histories }
    end
  end

  # GET /visiting_histories/1
  # GET /visiting_histories/1.json
  def show
    @visiting_history = VisitingHistory.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @visiting_history }
    end
  end

  # GET /visiting_histories/new
  # GET /visiting_histories/new.json
  def new
    @visiting_history = VisitingHistory.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @visiting_history }
    end
  end

  # GET /visiting_histories/1/edit
  def edit
    @visiting_history = VisitingHistory.find(params[:id])
  end

  # POST /visiting_histories
  # POST /visiting_histories.json
  def create
    @visiting_history = VisitingHistory.new(visiting_history_params)

    respond_to do |format|
      if @visiting_history.save
        format.html { redirect_to @visiting_history, notice: 'Visiting history was successfully created.' }
        format.json { render json: @visiting_history, status: :created, location: @visiting_history }
      else
        format.html { render action: "new" }
        format.json { render json: @visiting_history.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /visiting_histories/1
  # PATCH/PUT /visiting_histories/1.json
  def update
    @visiting_history = VisitingHistory.find(params[:id])

    respond_to do |format|
      if @visiting_history.update_attributes(visiting_history_params)
        format.html { redirect_to @visiting_history, notice: 'Visiting history was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @visiting_history.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /visiting_histories/1
  # DELETE /visiting_histories/1.json
  def destroy
    @visiting_history = VisitingHistory.find(params[:id])
    @visiting_history.destroy

    respond_to do |format|
      format.html { redirect_to visiting_histories_url }
      format.json { head :no_content }
    end
  end

  private

    # Use this method to whitelist the permissible parameters. Example:
    # params.require(:person).permit(:name, :age)
    # Also, you can specialize this method with per-user checking of permissible attributes.
    def visiting_history_params
      params.require(:visiting_history).permit(:day, :in_time, :latitude, :longitude, :out_time, :recorded_at, :resource_id, :user_id, :visiting_type, :visting_reason)
    end
end
