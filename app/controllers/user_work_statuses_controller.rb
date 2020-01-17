class UserWorkStatusesController < ApplicationController
  # GET /user_work_statuses
  # GET /user_work_statuses.json
  def index
    @user_work_statuses = UserWorkStatus.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @user_work_statuses }
    end
  end

  # GET /user_work_statuses/1
  # GET /user_work_statuses/1.json
  def show
    @user_work_status = UserWorkStatus.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @user_work_status }
    end
  end

  # GET /user_work_statuses/new
  # GET /user_work_statuses/new.json
  def new
    @user_work_status = UserWorkStatus.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @user_work_status }
    end
  end

  # GET /user_work_statuses/1/edit
  def edit
    @user_work_status = UserWorkStatus.find(params[:id])
  end

  # POST /user_work_statuses
  # POST /user_work_statuses.json
  def create
    @user_work_status = UserWorkStatus.new(user_work_status_params)

    respond_to do |format|
      if @user_work_status.save
        format.html { redirect_to @user_work_status, notice: 'User work status was successfully created.' }
        format.json { render json: @user_work_status, status: :created, location: @user_work_status }
      else
        format.html { render action: "new" }
        format.json { render json: @user_work_status.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /user_work_statuses/1
  # PATCH/PUT /user_work_statuses/1.json
  def update
    @user_work_status = UserWorkStatus.find(params[:id])

    respond_to do |format|
      if @user_work_status.update_attributes(user_work_status_params)
        format.html { redirect_to @user_work_status, notice: 'User work status was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @user_work_status.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /user_work_statuses/1
  # DELETE /user_work_statuses/1.json
  def destroy
    @user_work_status = UserWorkStatus.find(params[:id])
    @user_work_status.destroy

    respond_to do |format|
      format.html { redirect_to user_work_statuses_url }
      format.json { head :no_content }
    end
  end

  private

    # Use this method to whitelist the permissible parameters. Example:
    # params.require(:person).permit(:name, :age)
    # Also, you can specialize this method with per-user checking of permissible attributes.
    def user_work_status_params
      params.require(:user_work_status).permit(:latitude, :longitude, :recorded_at, :remarks, :user_id, :work_status)
    end
end
