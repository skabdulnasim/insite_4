class MoreInfosController < ApplicationController
  # GET /more_infos
  # GET /more_infos.json
  def index
    @more_infos = MoreInfo.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @more_infos }
    end
  end

  # GET /more_infos/1
  # GET /more_infos/1.json
  def show
    @more_info = MoreInfo.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @more_info }
    end
  end

  # GET /more_infos/new
  # GET /more_infos/new.json
  def new
    @more_info = MoreInfo.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @more_info }
    end
  end

  # GET /more_infos/1/edit
  def edit
    @more_info = MoreInfo.find(params[:id])
  end

  # POST /more_infos
  # POST /more_infos.json
  def create
    @more_info = MoreInfo.new(more_info_params)

    respond_to do |format|
      if @more_info.save
        format.html { redirect_to @more_info, notice: 'More info was successfully created.' }
        format.json { render json: @more_info, status: :created, location: @more_info }
      else
        format.html { render action: "new" }
        format.json { render json: @more_info.errors, status: :unprocessable_entity }
      end
    end
  end

  def save
    @name = params[:more_info]
    @more_info = MoreInfo.new
    @more_info[:name] = @name
    if @more_info.save
      @msg = "1"
    else
      @msg = "0"
    end
    
    respond_to do |format|
      format.json { render json: @msg }
    end
  end

  # PATCH/PUT /more_infos/1
  # PATCH/PUT /more_infos/1.json
  def update
    @more_info = MoreInfo.find(params[:id])

    respond_to do |format|
      if @more_info.update_attributes(more_info_params)
        format.html { redirect_to @more_info, notice: 'More info was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @more_info.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /more_infos/1
  # DELETE /more_infos/1.json
  def destroy
    @more_info = MoreInfo.find(params[:id])
    @more_info.destroy

    respond_to do |format|
      format.html { redirect_to more_infos_url }
      format.json { head :no_content }
    end
  end

  private

    # Use this method to whitelist the permissible parameters. Example:
    # params.require(:person).permit(:name, :age)
    # Also, you can specialize this method with per-user checking of permissible attributes.
    def more_info_params
      params.require(:more_info).permit(:name)
    end
end
