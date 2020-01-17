module CustomersHelper
  def wallet_balance(customer)
    return 9.0 if customer.try(:wallet)
    #return 'NA'
  end

  def labelled_amount(transaction)
    return transaction.payment_type=='debit' ? -transaction.amount : transaction.amount
  end
end
