class ProcessCompositionsController < ApplicationController
  # GET /process_compositions
  # GET /process_compositions.json
  def index
    @process_compositions = ProcessComposition.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @process_compositions }
    end
  end

  # GET /process_compositions/1
  # GET /process_compositions/1.json
  def show
    @process_composition = ProcessComposition.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @process_composition }
    end
  end

  # GET /process_compositions/new
  # GET /process_compositions/new.json
  def new
    @process_composition = ProcessComposition.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @process_composition }
    end
  end

  # GET /process_compositions/1/edit
  def edit
    @process_composition = ProcessComposition.find(params[:id])
  end

  # POST /process_compositions
  # POST /process_compositions.json
  def create
    @process_composition = ProcessComposition.new(process_composition_params)

    respond_to do |format|
      if @process_composition.save
        format.html { redirect_to @process_composition, notice: 'Process composition was successfully created.' }
        format.json { render json: @process_composition, status: :created, location: @process_composition }
      else
        format.html { render action: "new" }
        format.json { render json: @process_composition.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /process_compositions/1
  # PATCH/PUT /process_compositions/1.json
  def update
    @process_composition = ProcessComposition.find(params[:id])

    respond_to do |format|
      if @process_composition.update_attributes(process_composition_params)
        format.html { redirect_to @process_composition, notice: 'Process composition was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @process_composition.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /process_compositions/1
  # DELETE /process_compositions/1.json
  def destroy
    @process_composition = ProcessComposition.find(params[:id])
    @process_composition.destroy

    respond_to do |format|
      format.html { redirect_to process_compositions_url }
      format.json { head :no_content }
    end
  end

  private

    # Use this method to whitelist the permissible parameters. Example:
    # params.require(:person).permit(:name, :age)
    # Also, you can specialize this method with per-user checking of permissible attributes.
    def process_composition_params
      params.require(:process_composition).permit(:product_id, :production_process_id)
    end
end
