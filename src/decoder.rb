require 'singleton'

module DES

  class Decoder

    def self.decode(block)
      if block.nil?
        puts 'No block was given. Check your env-variable.'
      else
        puts "Decoding of #{block.inspect} started."



        puts "Decoding of #{block.inspect} finished."
      end
    end
  end
end
