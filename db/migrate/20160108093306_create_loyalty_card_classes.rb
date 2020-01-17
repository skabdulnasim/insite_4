class CreateLoyaltyCardClasses < ActiveRecord::Migration
  def change
    create_table :loyalty_card_classes do |t|
      t.string :name
      t.string :purchase_rule,  default: {:point=> 1, :amount=>1}
      t.string :reward_rule,    default: {:point=> 1, :amount=>1}
      t.string :debit_rule,     default: {:point=> 1, :amount=>1}

      t.timestamps
    end
  end
end
