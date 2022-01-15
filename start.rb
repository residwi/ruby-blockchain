# frozen_string_literal: true

require 'json'
require 'openssl'
Dir[File.join(__dir__, 'blockchain', '*.rb')].sort.each { |file| require file }

resi = Wallet.new
dwi = Wallet.new
thawasa = Wallet.new

resi.send_money(amount: 100, to: dwi.address)
dwi.send_money(amount: 27, to: thawasa.address)
thawasa.send_money(amount: 5, to: resi.address)

# puts Chain.print
