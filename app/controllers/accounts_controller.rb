class AccountsController < ApplicationController
  # GET /accounts
  # GET /accounts.json
  load_and_authorize_resource
  def index
    @accounts = Account.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @tax_groups }
    end
  end

  # DELETE /accounts/1
  # DELETE /accounts/1.json
  def destroy
    @accounts = Account.find(params[:id])
    # @accounts.destroy
    # Apartment::Database.drop(@accounts[:subdomain])

    respond_to do |format|
      format.html { redirect_to accounts_url , notice: 'You have successfully deleted the account and droped the database' }
      format.json { head :no_content }
    end
  end
end