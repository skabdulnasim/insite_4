module PaytmHelper
	require 'paytm/encryption_new_pg.rb'
  include EncryptionNewPG
  def generate_checksum
    new_pg_checksum(@paramList, @paytm_keys.paytm_marchant_key).gsub("\n",'')
  end

  def verify_checksum
    new_pg_verify_checksum(@paramList, @checksum_hash, @paytm_keys.paytm_marchant_key)
  end

  def refund_generate_checksum
  	new_pg_refund_checksum(@paramList, @paytm_keys.paytm_marchant_key).gsub("\n",'')
  end
end

