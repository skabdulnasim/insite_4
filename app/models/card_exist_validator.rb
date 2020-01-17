class CardExistValidator < ActiveModel::Validator
  def validate(record)
    unless LoyaltyCard.find_card(record.card_identity).first.present?
      record.errors.add(:base, I18n.t(:error_loyalty_card_not_found))
    end
  end
end