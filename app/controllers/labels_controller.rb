class LabelsController < ApplicationController
  # GET /labels
  # GET /labels.json
  def index
    @labels = Label.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @labels }
    end
  end

  # GET /labels/1
  # GET /labels/1.json
  def show
    @label = Label.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @label }
    end
  end

  # GET /labels/new
  # GET /labels/new.json
  def new
    @label = Label.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @label }
    end
  end

  # GET /labels/1/edit
  def edit
    @label = Label.find(params[:id])
  end

  # POST /labels
  # POST /labels.json
  def create
    @label = Label.new(label_params)

    respond_to do |format|
      if @label.save
        format.html { redirect_to @label, notice: 'Label was successfully created.' }
        format.json { render json: @label, status: :created, location: @label }
      else
        format.html { render action: "new" }
        format.json { render json: @label.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /labels/1
  # PATCH/PUT /labels/1.json
  def update
    @label = Label.find(params[:id])

    respond_to do |format|
      if @label.update_attributes(label_params)
        format.html { redirect_to @label, notice: 'Label was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @label.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /labels/1
  # DELETE /labels/1.json
  def destroy
    @label = Label.find(params[:id])
    @label.destroy

    respond_to do |format|
      format.html { redirect_to labels_url }
      format.json { head :no_content }
    end
  end

  private

    # Use this method to whitelist the permissible parameters. Example:
    # params.require(:person).permit(:name, :age)
    # Also, you can specialize this method with per-user checking of permissible attributes.
    def label_params
      params.require(:label).permit(:name, :status, :customer_state, :icon)
    end
end
