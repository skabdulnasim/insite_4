class AddBeneficiaryPercentageToBeneficiaries < ActiveRecord::Migration
  def change
    add_column :beneficiaries, :beneficiary_percentage, :string
  end
end
