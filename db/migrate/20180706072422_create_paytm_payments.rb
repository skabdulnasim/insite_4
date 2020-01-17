class CreatePaytmPayments < ActiveRecord::Migration
  def change
    create_table :paytm_payments do |t|
      t.string :TXNID
      t.string :BANKTXNID
      t.string :ORDERID
      t.string :TXNAMOUNT
      t.string :STATUS
      t.string :TXNTYPE
      t.string :GATEWAYNAME
      t.string :RESPCODE
      t.string :RESPMSG
      t.string :BANKNAME
      t.string :MID
      t.string :PAYMENTMODE
      t.string :REFUNDAMT
      t.datetime :TXNDATE

      t.timestamps
    end
  end
end
