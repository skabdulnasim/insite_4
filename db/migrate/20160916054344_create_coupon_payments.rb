class CreateCouponPayments < ActiveRecord::Migration
  def change
    create_table :coupon_payments do |t|
      t.string :no
      t.date :validity
      t.string :name
      t.string :provider
      t.string :denomination
      t.integer :amount
      t.integer :coupon_id
      t.timestamps
    end

    coupons = Coupon.all
    coupons.each do |coupon|
      puts coupon.id
      _new_coupon_payment = CouponPayment.new
      _new_coupon_payment[:no] = coupon.no if coupon.no.present?
      _new_coupon_payment[:validity] = coupon.validity if coupon.validity.present?
      _new_coupon_payment[:name] = coupon.name if coupon.name.present?
      _new_coupon_payment[:provider] = coupon.provider if coupon.provider.present?
      _new_coupon_payment[:denomination] = coupon.denomination if coupon.denomination.present?
      _new_coupon_payment[:amount] = coupon.amount if coupon.amount.present?
      _new_coupon_payment[:created_at] = coupon.created_at if coupon.created_at.present?
      _new_coupon_payment[:updated_at] = coupon.updated_at if coupon.updated_at.present?
      _new_coupon_payment.save!
    end

    if column_exists? :coupons, :amount
      remove_column :coupons, :amount 
    end
    if column_exists? :coupons, :denomination
      remove_column :coupons, :denomination
    end
    if column_exists? :coupons, :no
      remove_column :coupons, :no
    end
    if column_exists? :coupons, :provider
      remove_column :coupons, :provider
    end
    if column_exists? :coupons, :validity
      remove_column :coupons, :validity
    end

    Coupon.delete_all if (table_exists? :coupons)

  end
end
