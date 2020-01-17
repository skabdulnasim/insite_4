class AddBeneficiaryTypeToBeneficiary < ActiveRecord::Migration
  def change
    add_column :beneficiaries, :benificiary_type, :string
  end
end
