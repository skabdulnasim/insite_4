class TagGroupsController < ApplicationController
  # GET /tag_groups
  # GET /tag_groups.json
  def index
    @tag_groups = TagGroup.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @tag_groups }
    end
  end

  # GET /tag_groups/1
  # GET /tag_groups/1.json
  def show
    @tag_group = TagGroup.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @tag_group }
    end
  end

  # GET /tag_groups/new
  # GET /tag_groups/new.json
  def new
    @tag_group = TagGroup.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @tag_group }
    end
  end

  # GET /tag_groups/1/edit
  def edit
    @tag_group = TagGroup.find(params[:id])
  end

  # POST /tag_groups
  # POST /tag_groups.json
  def create
    @tag_group = TagGroup.new(tag_group_params)

    respond_to do |format|
      if @tag_group.save
        format.html { redirect_to @tag_group, notice: 'Tag group was successfully created.' }
        format.json { render json: @tag_group, status: :created, location: @tag_group }
      else
        format.html { render action: "new" }
        format.json { render json: @tag_group.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /tag_groups/1
  # PATCH/PUT /tag_groups/1.json
  def update
    @tag_group = TagGroup.find(params[:id])

    respond_to do |format|
      if @tag_group.update_attributes(tag_group_params)
        format.html { redirect_to @tag_group, notice: 'Tag group was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @tag_group.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /tag_groups/1
  # DELETE /tag_groups/1.json
  def destroy
    @tag_group = TagGroup.find(params[:id])
    @tag_group.destroy

    respond_to do |format|
      format.html { redirect_to tag_groups_url }
      format.json { head :no_content }
    end
  end

  private

    # Use this method to whitelist the permissible parameters. Example:
    # params.require(:person).permit(:name, :age)
    # Also, you can specialize this method with per-user checking of permissible attributes.
    def tag_group_params
      params.require(:tag_group).permit(:name)
    end
end