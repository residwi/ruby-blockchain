class Block
  attr_accessor :hash, :previous_hash, :transaction, :timestamp, :nonce

  def self.build(hash)
    new.tap do |b|
      b.previous_hash = hash[:previous_hash]
      b.nonce = hash[:nonce] || Digest::MD5.hexdigest((rand(1000) * 999_999_999).to_s)
      b.transaction = hash[:transaction]
      b.timestamp = hash[:timestamp] || Time.now
      b.hash = hash[:hash] || Digest::SHA256.hexdigest(b.to_hash.to_json)
    end
  end

  def to_hash
    instance_variables
      .each_with_object({}) { |v, hash| hash[v.to_s.delete('@').to_sym] = instance_variable_get(v) }
  end
end
