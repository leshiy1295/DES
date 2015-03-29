require 'singleton'
require_relative 'algorithm_parameters'
require_relative 'algorithm_helper'

module DES

  class Encoder

    def self.encode(block)
      if block.nil?
        puts 'ERROR: No block was given. Check your env-variable.'
      else
        puts "ENCODING of #{block.inspect} STARTED."
        puts '====================================='

        puts 'Bit representation of block'
        DES::AlgorithmHelper.show_bit_representation(block)

        puts '====================================='
        puts 'FIRST STAGE - first permutation'
        puts '====================================='

        block = DES::AlgorithmHelper.affect_with_first_permutation(block)

        puts 'Bit representation of block'
        DES::AlgorithmHelper.show_bit_representation(block)

        puts '====================================='
        puts 'SECOND STAGE - partition to left and right subblocks'
        puts '====================================='

        puts 'Bit representation of left block'
        DES::AlgorithmHelper.show_bit_representation(block[0..3])

        puts 'Bit representation of right block'
        DES::AlgorithmHelper.show_bit_representation(block[4..-1])

        puts '====================================='
        puts 'THIRD STAGE - 16 rounds of encryption'
        puts '====================================='

        16.times do |_|
          puts "Round #{_ + 1}"
          right = do_round_with_right_subblock(_ + 1, block[0..3], block[4..-1])
          # left = right
          (0..3).each do |__|
            block[__] = block[4 + __]
          end
          # right = returned result
          (4..7).each do |__|
            block[__] = right[__ - 4]
          end
          puts '==================================='
          puts "ROUND #{_ + 1} RESULT"
          puts 'Bit representation of left'
          DES::AlgorithmHelper.show_bit_representation(block[0..3])
          puts 'Bit representation of right'
          DES::AlgorithmHelper.show_bit_representation(block[4..-1])
        end

        puts '====================================='
        puts 'FOURTH STAGE - concatenation of left and right subblocks to one block'
        puts '====================================='

        puts 'Bit representation of block'
        DES::AlgorithmHelper.show_bit_representation(block)

        puts '====================================='
        puts 'LAST STAGE - inverse permutation'
        puts '====================================='

        block = DES::AlgorithmHelper.affect_with_inverse_permutation(block)

        puts "ENCODING FINISHED. RESULT: #{block.inspect}"
        DES::AlgorithmParameters.set_block_to_decode(block)
        DES::AlgorithmHelper.show_bit_representation(block)
      end
    end

    def self.do_round_with_right_subblock(round_number, left, right)
      key = DES::AlgorithmParameters.get_round_keys[round_number - 1]
      function = DES::AlgorithmHelper.feistel_function(right, key)
      puts "------------------------------------------"
      puts "ROUND XOR"
      puts "------------------------------------------"
      right = DES::AlgorithmHelper.do_xor(left, function)
      puts 'Bit representation of block'
      DES::AlgorithmHelper.show_bit_representation(right)
      right
    end
  end
end
