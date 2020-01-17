class PosTerminalsController < ApplicationController
  load_and_authorize_resource

  layout :resolve_layout

  before_filter :set_module_details

  # GET /pos_terminals
  # GET /pos_terminals.json
  def index
    @pos_terminals = PosTerminal.unit_pos(current_user.unit_id).not_trashed
    @menu_cards = MenuCard.set_unit(current_user.unit_id).active.not_trashed
  end

  # GET /pos_terminals/1
  # GET /pos_terminals/1.json
  def show
    @pos = PosTerminal.find(params[:id])
    if @pos_terminal.menu_card_id.present?
      @catalog = MenuCard.find(@pos_terminal.menu_card_id)
    else
      redirect_to edit_pos_terminal_path(@pos_terminal)
    end
  end

  # GET /pos_terminals/new
  # GET /pos_terminals/new.json
  def new
    @pos_terminal = PosTerminal.new
    @catalogs = MenuCard.by_unit_in(get_pos_units(@pos_terminal)).active
  end

  # GET /pos_terminals/1/edit
  def edit
    @pos_terminal = PosTerminal.find(params[:id])
    @catalogs = MenuCard.by_unit_in(get_pos_units(@pos_terminal)).active
  end

  # POST /pos_terminals
  # POST /pos_terminals.json
  def create
    @pos_terminal = PosTerminal.new(params[:pos_terminal])
    @pos_terminal[:unit_id] = current_user.unit_id
    if @pos_terminal.save
      redirect_to @pos_terminal, notice: 'Pos terminal was successfully created.'
    else
      render action: "new"
    end
  end

  # PATCH/PUT /pos_terminals/1
  # PATCH/PUT /pos_terminals/1.json
  def update
    @pos_terminal = PosTerminal.find(params[:id])
    if @pos_terminal.update_attributes(params[:pos_terminal])
      redirect_to pos_terminals_path, notice: 'Pos terminal was successfully updated.'
    else
      render action: "edit"
    end
  end

  # DELETE /pos_terminals/1
  # DELETE /pos_terminals/1.json
  def destroy
    @pos_terminal = PosTerminal.find(params[:id])
    @pos_terminal.destroy
    redirect_to pos_terminals_url
  end

  def find_barcode
    @pos = PosTerminal.find(params[:id])
    @catalog = MenuCard.find(params[:catalog_id])
    _store_ids = MenuProduct.by_menu_card(@catalog.id).uniq.pluck(:store_id)
    @stocks = Stock.by_sku(params[:sku]).set_store_in(_store_ids).available
  end

  def find_product
    @pos = PosTerminal.find(params[:id])
    @catalog = MenuCard.find(params[:catalog_id])
    _store_ids = MenuProduct.by_menu_card(@catalog.id).uniq.pluck(:store_id)
    @stocks = Stock.by_product_name(params[:product_name]).set_store_in(_store_ids).available
    @product = Product.by_product_name(params[:product_name]).first
    @menu_product = @product.menu_products.by_menu_card(@catalog.id).first if @product.present?
    @stock_check_on_order = AppConfiguration.get_config_value('stock_check_on_order')
  end

  def tally_exporter
    cookies['fileDownload'] = 'true'
    respond_to do |format|
      format.xls { send_data Bill.to_tally_csv(params[:pos_id], params[:bill_serial_prefix], col_sep: "\t"), x_sendfile: true }
    end
  end

  def page
  end

  def file
    cookies['fileDownload'] = 'true'
    send_file tally_exporter_pos_terminals_path(format: :xlsx),
      type: 'content-type',
      x_sendfile: true
  end

  private

  def resolve_layout
    case action_name
    when "show"
      "materialize_pos"
    when "edit"
      "materialize_pos"
    when "new"
      "materialize_pos"
    else
      "material"
    end
  end

  def set_module_details
    @module_id = "pos_terminals"
    @module_title = "POS Terminals"
  end

  # Use this method to whitelist the permissible parameters. Example:
  # params.require(:person).permit(:name, :age)
  # Also, you can specialize this method with per-user checking of permissible attributes.

  def customer_params
    {
      "email"                         => "",
      "password"                      => "12345678",
      "mobile_no"                     => params[:contact_no],
      "profile_attributes[firstname]" => params[:firstname],
      "profile_attributes[lastname]"  => params[:lastname],
      "profile_attributes[contact_no]"=> params[:contact_no]
    }
  end

  def address_params(customer_id)
    {
      "customer_id"         => customer_id,
      "delivery_address"    => params[:delivery_address],
      "city"                => params[:city],
      "state"               => params[:state],
      "landmark"            => params[:landmark],
      "pincode"             => params[:pincode],
      "latitude"            => '0',
      "longitude"           => '0',
      "contact_no"          => params[:contact_no],
      "receiver_first_name" => params[:firstname],
      "receiver_last_name"  => params[:lastname]
    }
  end

  def get_pos_units pos, units=[]
     if pos.capability == 'self_unit'
      units.push(current_user.unit_id)
    elsif pos.capability == 'self_and_child_units'
      units.push(current_user.unit_id)
    else
      units = Unit.all.map { |e| e.id }
    end
    units
  end
end
