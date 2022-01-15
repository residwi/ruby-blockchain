class Wallet
  def initialize
    @public_key = keypair.public_key.to_s
    @private_key = keypair.to_s
  end

  def address
    @public_key
  end

  def send_money(amount:, to:)
    transaction = Transaction.build(amount: amount, sender: @public_key, to: to)
    signature = keypair.sign(OpenSSL::Digest.new('SHA256'), transaction.json)
    Chain.add_block(transaction: transaction, address: @public_key, signature: signature)
  end

  private

  def keypair
    @keypair ||= OpenSSL::PKey::RSA.new(2048)
  end
end
