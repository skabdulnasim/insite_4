class DocTypesController < ApplicationController
  # GET /doc_types
  # GET /doc_types.json
  def index
    @doc_types = DocType.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @doc_types }
    end
  end

  # GET /doc_types/1
  # GET /doc_types/1.json
  def show
    @doc_type = DocType.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @doc_type }
    end
  end

  # GET /doc_types/new
  # GET /doc_types/new.json
  def new
    @doc_type = DocType.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @doc_type }
    end
  end

  # GET /doc_types/1/edit
  def edit
    @doc_type = DocType.find(params[:id])
  end

  # POST /doc_types
  # POST /doc_types.json
  def create
    @doc_type = DocType.new(doc_type_params)

    respond_to do |format|
      if @doc_type.save
        format.html { redirect_to @doc_type, notice: 'Doc type was successfully created.' }
        format.json { render json: @doc_type, status: :created, location: @doc_type }
      else
        format.html { render action: "new" }
        format.json { render json: @doc_type.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /doc_types/1
  # PATCH/PUT /doc_types/1.json
  def update
    @doc_type = DocType.find(params[:id])

    respond_to do |format|
      if @doc_type.update_attributes(doc_type_params)
        format.html { redirect_to @doc_type, notice: 'Doc type was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @doc_type.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /doc_types/1
  # DELETE /doc_types/1.json
  def destroy
    @doc_type = DocType.find(params[:id])
    @doc_type.destroy

    respond_to do |format|
      format.html { redirect_to doc_types_url }
      format.json { head :no_content }
    end
  end

  private

    # Use this method to whitelist the permissible parameters. Example:
    # params.require(:person).permit(:name, :age)
    # Also, you can specialize this method with per-user checking of permissible attributes.
    def doc_type_params
      params.require(:doc_type).permit(:title)
    end
end
