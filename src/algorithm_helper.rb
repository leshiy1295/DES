require_relative 'algorithm_parameters'

module DES

  class AlgorithmHelper

    def self.get_bit_by_number(number, block)
      char = block[(number - 1) / 8].ord
      char & (1 << (7 - (number - 1) % 8)) != 0
    end

    def self.set_bit_by_number(number, bit, block)
      unfreezed_copy = block.dup
      char = unfreezed_copy[(number - 1) / 8].ord
      if !bit
        char &= ~(1 << (7 - (number - 1) % 8))
      else
        char |= (1 << (7 - (number - 1) % 8))
      end
      unfreezed_copy[(number - 1) / 8] = char.chr(Encoding::ASCII_8BIT)
      unfreezed_copy
    end
  end
end
