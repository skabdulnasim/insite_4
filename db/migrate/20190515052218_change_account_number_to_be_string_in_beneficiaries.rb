class ChangeAccountNumberToBeStringInBeneficiaries < ActiveRecord::Migration
  def chnage
  	change_column :beneficiaries, :account_number, :string 
  end
end
