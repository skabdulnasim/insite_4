class RenameBenificiaryTypeToBeneficiaryTypeInBeneficiary < ActiveRecord::Migration
  def up
  	rename_column :beneficiaries, :benificiary_type, :beneficiary_type
  end

  def down
  end
end
