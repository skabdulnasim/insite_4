class ChangeAccountNoToString < ActiveRecord::Migration
  def change
    change_column :beneficiaries, :account_number, :string
  end
end
