class PayUpdate < ActiveRecord::Base
  attr_accessible :unit_id, :current_cash
  validates :current_cash,      :presence => true
  validates :unit_id,      :presence => true

  def self.current_cash(unit_id)
    _last_update = PayUpdate.where(["unit_id = ? ", unit_id]).last
    if _last_update.present?
      return _last_update.current_cash
    else
      return 0
    end 
  end

  def self.update_pay(unit_id,credit_amount,debit_amount,_pay_id)
    _current_pay = PayUpdate.current_cash(unit_id)
    _new_pay = (_current_pay.to_f + credit_amount.to_f - debit_amount.to_f)
    PayUpdate.create(:unit_id => unit_id, :current_cash=>_new_pay)
  end   
end
