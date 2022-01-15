class Chain
  class << self
    # Add a new block to the chain if valid signature & valid chain & proof of work is complete
    def add_block(transaction:, address:, signature:)
      @blockchain = read_from_file
      @blockchain.push({ block: init_genesis_block }) if @blockchain.size.zero?

      # verify transaction
      keypair = OpenSSL::PKey::RSA.new(address)
      block_valid = keypair.verify(OpenSSL::Digest.new('SHA256'), signature, transaction.json)

      unless block_valid && chain_valid?
        puts 'Not valid! Chain has been tampered'
        return
      end

      new_block = Block.build(
        previous_hash: last_block[:hash],
        transaction: transaction.tap(&:encrypt_address).to_hash
      )

      mine!(new_block.nonce)
      @blockchain.push({ block: new_block.to_hash })
      save_to_blockchain
    end

    def chain_valid?
      @blockchain
        .map.with_index { |_, index| block_valid?(index) }
        .all?
    end

    def print
      JSON.pretty_generate read_from_file
    end

    private

    # Proof of work system
    def mine!(nonce)
      solution = 1
      puts '⛏️  mining...'

      loop do
        hash = Digest::MD5.hexdigest "#{nonce}#{solution}"

        if hash.start_with?('0000')
          puts "Solved: #{solution}"
          break
        end

        solution += 1
      end
    end

    def last_block
      @blockchain.last[:block]
    end

    def read_from_file
      file = File.read('blockchain.json')
      JSON.parse(file, symbolize_names: true)
    end

    def save_to_blockchain
      File.write('blockchain.json', JSON.pretty_generate(@blockchain))
    end

    def init_genesis_block
      Block.build(
        previous_hash: '0000000',
        nonce: '0000000',
        transaction: Transaction.build(amount: 1_000_000, sender: 'GENESIS', to: 'world').to_hash
      ).to_hash
    end

    def block_valid?(index)
      return true if index.zero? # genesis block will not be checked

      current_block = @blockchain[index][:block]
      previous_block = @blockchain[index - 1][:block]
      block = Block.build(current_block.except(:hash)) # recalculate the hash of the block

      current_block[:hash] == block.hash && current_block[:previous_hash] == previous_block[:hash]
    end
  end
end
