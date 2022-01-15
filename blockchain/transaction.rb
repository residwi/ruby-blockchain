class Transaction
  attr_accessor :amount, :sender, :to

  def self.build(hash)
    new.tap do |b|
      b.amount = hash[:amount]
      b.sender = hash[:sender]
      b.to = hash[:to]
    end
  end

  def encrypt_address
    @sender = Digest::SHA1.hexdigest @sender
    @to = Digest::SHA1.hexdigest @to
  end

  def to_hash
    instance_variables
      .each_with_object({}) { |v, hash| hash[v.to_s.delete('@').to_sym] = instance_variable_get(v) }
  end

  def json
    to_hash.to_json
  end
end
