class CombinationsRulesController < ApplicationController
  # GET /combinations_rules
  # GET /combinations_rules.json
  load_and_authorize_resource
  def index
    @combinations_rules = CombinationsRule.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @combinations_rules }
    end
  end

  # GET /combinations_rules/1
  # GET /combinations_rules/1.json
  def show
    @combinations_rule = CombinationsRule.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @combinations_rule }
    end
  end

  # GET /combinations_rules/new
  # GET /combinations_rules/new.json
  def new
    @combinations_rule = CombinationsRule.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @combinations_rule }
    end
  end

  # GET /combinations_rules/1/edit
  def edit
    @combinations_rule = CombinationsRule.find(params[:id])
  end

  # POST /combinations_rules
  # POST /combinations_rules.json
  def create
    @combinations_rule = CombinationsRule.new(params[:combinations_rule])

    respond_to do |format|
      if @combinations_rule.save
        format.html { redirect_to menu_cards_manage_settings_path, notice: 'Combinations rule was successfully created.' }
        format.json { render json: @combinations_rule, status: :created, location: @combinations_rule }
      else
        format.html { redirect_to menu_cards_manage_settings_path, notice: 'Something went wrong while creating combiintion rule.' }
        format.json { render json: @combinations_rule.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /combinations_rules/1
  # PUT /combinations_rules/1.json
  def update
    @combinations_rule = CombinationsRule.find(params[:id])

    respond_to do |format|
      if @combinations_rule.update_attributes(params[:combinations_rule])
        format.html { redirect_to menu_cards_manage_settings_path, notice: 'Combinations rule was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { redirect_to menu_cards_manage_settings_path, notice: 'Something went wrong while updating combiintion rule.' }
        format.json { render json: @combinations_rule.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /combinations_rules/1
  # DELETE /combinations_rules/1.json
  def destroy
    @combinations_rule = CombinationsRule.find(params[:id])
    @combinations_rule.destroy

    respond_to do |format|
      format.html { redirect_to menu_cards_manage_settings_path, notice: 'Combination rule deleted.' }
      format.json { head :no_content }
    end
  end
end
