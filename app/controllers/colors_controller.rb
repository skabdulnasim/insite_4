class ColorsController < ApplicationController
  # GET /colors
  # GET /colors.json
  def index
    @colors = Color.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @colors }
    end
  end

  # GET /colors/1
  # GET /colors/1.json
  def show
    @color = Color.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @color }
    end
  end

  # GET /colors/new
  # GET /colors/new.json
  def new
    @color = Color.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @color }
    end
  end

  # GET /colors/1/edit
  def edit
    @color = Color.find(params[:id])
  end

  # POST /colors
  # POST /colors.json
  def create
    @color = Color.new(color_params)

    respond_to do |format|
      if @color.save
        format.html { redirect_to @color, notice: 'Color was successfully created.' }
        format.json { render json: @color, status: :created, location: @color }
      else
        format.html { render action: "new" }
        format.json { render json: @color.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /colors/1
  # PATCH/PUT /colors/1.json
  def update
    @color = Color.find(params[:id])

    respond_to do |format|
      if @color.update_attributes(color_params)
        format.html { redirect_to @color, notice: 'Color was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @color.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /colors/1
  # DELETE /colors/1.json
  def destroy
    @color = Color.find(params[:id])
    @color.destroy

    respond_to do |format|
      format.html { redirect_to colors_url }
      format.json { head :no_content }
    end
  end

  private

    # Use this method to whitelist the permissible parameters. Example:
    # params.require(:person).permit(:name, :age)
    # Also, you can specialize this method with per-user checking of permissible attributes.
    def color_params
      params.require(:color).permit(:name, :code)
    end
end
