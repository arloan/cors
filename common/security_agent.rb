#!/usr/bin/env ruby
# encoding: utf-8

require "openssl"

class SecurityAgent
  ALGORITHM	= 'aes-128-cbc'

  def initialize
    @cipher = OpenSSL::Cipher::new(ALGORITHM)
  end

	def encrypt(plain, key, iv)
		raise ArgumentError, 'invalid key: bad length' if key.length != 16
		raise ArgumentError, 'invalid iv: bad length' if iv && iv.length != 16
		@cipher.encrypt
		@cipher.key = key
		@cipher.iv = iv
		@cipher.update(plain) + @cipher.final
	end
  def decrypt(bin_enc, key, iv)
    raise ArgumentError, 'invalid key: bad length' if key.length != 16
		raise ArgumentError, 'invalid iv: bad length' if iv && iv.length != 16
		@cipher.decrypt
    @cipher.key = key
		@cipher.iv = iv
    @cipher.update(bin_enc) + @cipher.final
  end
  def decrypt_hexkey(bin_enc, hexkey, iv)
    key = hex2bin(hexkey)
    decrypt(bin_enc, key, iv)
  end
  def hex2bin(hex)
    [hex].pack('H*')
  end
  def bin2hex(bin)
    bin.unpack('H*').first
  end
end
