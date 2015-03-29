require_relative 'algorithm_parameters'

module DES

  class AlgorithmHelper

    def self.do_xor(first, second)
      puts 'Bit representation of first xor operand'
      show_bit_representation(first)
      puts 'Bit representation of second xor operand'
      show_bit_representation(second)
      len = first.length
      (0..len - 1).each do |_|
        first_char = first[_].ord
        second_char = second[_].ord
        first_char ^= second_char
        first[_] = first_char.chr
      end
      first
    end

    def self.affect_with_key_shift(key)
      shifted_key = key
      ind = 1
      DES::AlgorithmParameters.get_key_shift.each do |_|
        bit = get_bit_by_number(_, key)
        shifted_key = set_bit_by_number(ind, bit, shifted_key)
        ind += 1
      end
      shifted_key
    end

    def self.affect_with_key_permutation(block)
      permutated_block = "\0" * 6
      ind = 1
      DES::AlgorithmParameters.get_key_permutation.each do |_|
        bit = get_bit_by_number(_, block)
        permutated_block = set_bit_by_number(ind, bit, permutated_block)
        ind += 1
      end
      permutated_block
    end

    def self.affect_with_extended_key_permutation(block)
      permutated_block = "\0" * 7
      ind = 1
      DES::AlgorithmParameters.get_extended_key_permutation.each do |_|
        bit = DES::AlgorithmHelper.get_bit_by_number(_, block)
        permutated_block = set_bit_by_number(ind, bit, permutated_block)
        ind += 1
      end
      permutated_block
    end

    def self.show_bit_representation(block)
      block.chars.each do |char|
        printf("%08d\n", char.ord.to_s(2))
      end
    end

    def self.affect_with_first_permutation(block)
      permutated_block = block
      ind = 1
      DES::AlgorithmParameters.get_start_permutation.each do |_|
        bit = DES::AlgorithmHelper.get_bit_by_number(_, block)
        permutated_block = DES::AlgorithmHelper.set_bit_by_number(ind, bit, permutated_block)
        ind += 1
      end
      permutated_block
    end

    def self.get_round_key(round_number)
      if round_number == 1
        key = DES::AlgorithmParameters.get_key
        puts "KEY: #{key.inspect}"

        puts 'Bit representation of key'
        show_bit_representation(key)

        puts "%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%"
        puts "EXTENDED KEY PERMUTATION"
        puts "%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%"

        key = affect_with_extended_key_permutation(key)

        puts 'Bit representation of key'
        show_bit_representation(key)
        puts "%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%"
        puts "PARTITION"
        puts "%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%"

        key_left = key[0..3]
        char = key_left[3].ord & ~15
        key_left[3] = char.chr

        key_right = "\0" * 4
        (3..5).each do |_|
          char = ((key[_].ord & 15) << 4) | ((key[_ + 1].ord & ~15) >> 4)
          key_right[_ - 3] = char.chr
        end
        char = key_right[3].ord & ~15
        key_right[3] = char.chr
      else
        key_left = @@key_left
        key_right = @@key_right
      end
      puts 'Bit representation of key left'
      show_bit_representation(key_left)

      puts 'Bit representation of key right'
      show_bit_representation(key_right)
      puts "%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%"
      puts "SHIFT"
      puts "%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%"

      key_left = shift_key(key_left, round_number)

      puts 'Bit representation of key left'
      show_bit_representation(key_left)

      key_right = shift_key(key_right, round_number)

      puts 'Bit representation of key right'
      show_bit_representation(key_right)

      @@key_left = key_left
      @@key_right = key_right
      puts "%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%"
      puts "CONCATENATION"
      puts "%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%"

      key = "\0" * 7

      (0..3).each do |_|
        key[_] = key_left[_]
      end
      char = key[3].ord
      char |= (key_right[0].ord & ~15) >> 4
      key[3] = char.chr
      (0..2).each do |_|
        char = ((key_right[_].ord & 15) << 4) | ((key_right[_ + 1].ord & ~15) >> 4)
        key[4 + _] = char.chr
      end

      puts 'Bit representation of key'
      show_bit_representation(key)

      puts "%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%"
      puts "PERMUTATION"
      puts "%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%"

      key = affect_with_key_permutation(key)

      puts 'Bit representation of key'
      show_bit_representation(key)

      key
    end

    def self.shift_key(key, round_number)
      DES::AlgorithmParameters.get_shift_count[round_number - 1].times do
        key = affect_with_key_shift(key)
      end
      key
    end

    def self.create_round_keys
      keys = Array.new
      16.times do |_|
        puts "Generating key for round #{_ + 1}"
        key = get_round_key(_ + 1)
        keys.push(key)
      end
      DES::AlgorithmParameters.set_round_keys(keys)
    end

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
      unfreezed_copy[(number - 1) / 8] = char.chr
      unfreezed_copy
    end

    def self.feistel_function(block, key)
      puts "------------------------------------------"
      puts "FEISTEL FUNCTION"
      puts "------------------------------------------"
      puts 'Bit representation of block'
      show_bit_representation(block)
      puts "------------------------------------------"
      puts "EXTENSION"
      puts "------------------------------------------"
      block = extend(block)
      puts 'Bit representation of block'
      show_bit_representation(block)

      puts "------------------------------------------"
      puts "XOR WITH KEY"
      puts "------------------------------------------"
      block = do_xor(block, key)
      puts 'Bit representation of block'
      show_bit_representation(block)

      puts "------------------------------------------"
      puts "PARTITION"
      puts "------------------------------------------"
      subblocks = ["\0"] * 8

      char = block[0].ord & ~3
      subblocks[0] = char.chr
      char = ((block[0].ord & 3) << 6) | ((block[1].ord & ~15) >> 2)
      subblocks[1] = char.chr
      char = ((block[1].ord & 15) << 4) | ((block[2].ord & ~63) >> 4)
      subblocks[2] = char.chr
      char = ((block[2].ord & 63) << 2)
      subblocks[3] = char.chr
      char = block[3].ord & ~3
      subblocks[4] = char.chr
      char = ((block[3].ord & 3) << 6) | ((block[4].ord & ~15) >> 2)
      subblocks[5] = char.chr
      char = ((block[4].ord & 15) << 4) | ((block[5].ord & ~63) >> 4)
      subblocks[6] = char.chr
      char = ((block[5].ord & 63) << 2)
      subblocks[7] = char.chr

      (0..7).each do |_|
        puts "subblock[#{_}] before s_box:"
        show_bit_representation(subblocks[_])
      end

      (0..7).each do |_|
        subblocks[_] = replace_subblock_with_s_box(_, subblocks[_])
        puts "subblock[#{_}] after s_box:"
        show_bit_representation(subblocks[_])
      end

      puts "------------------------------------------"
      puts "CONCATENATION"
      puts "------------------------------------------"

      block = "\0" * 4
      (0..3).each do |_|
        char = subblocks[2 * _].ord << 4 | subblocks[2 * _ + 1].ord
        block[_] = char.chr
      end

      puts 'Bit representation of block'
      show_bit_representation(block)

      puts "------------------------------------------"
      puts "PERMUTATION"
      puts "------------------------------------------"

      block = affect_with_feitsel_permutation(block)

      puts 'Bit representation of block'
      show_bit_representation(block)

      block
    end

    def self.extend(block)
      extended_block = "\0" * 6
      # first bit is 32 bit from block
      bit = get_bit_by_number(32, block)
      extended_block = set_bit_by_number(1, bit, extended_block)
      ind = 2
      (1..5).each do |_|
        bit = get_bit_by_number(_, block)
        extended_block = set_bit_by_number(ind, bit, extended_block)
        ind += 1
      end
      bit_number = 4
      while ind <= 42 do
        6.times do
          bit = get_bit_by_number(bit_number, block)
          extended_block = set_bit_by_number(ind, bit, extended_block)
          bit_number += 1
          ind += 1
        end
        bit_number -= 2
      end
      (43..47).each do |_|
        bit = get_bit_by_number(bit_number, block)
        extended_block = set_bit_by_number(_, bit, extended_block)
        bit_number += 1
      end
      # last bit is 1 bit from block
      bit = get_bit_by_number(1, block)
      extended_block = set_bit_by_number(48, bit, extended_block)
      extended_block
    end

    def self.replace_subblock_with_s_box(number, subblock)
      row = "\0"
      bit = get_bit_by_number(1, subblock)
      row = set_bit_by_number(7, bit, row)
      bit = get_bit_by_number(6, subblock)
      row = set_bit_by_number(8, bit, row)
      column = (subblock.ord & 120) >> 3
      DES::AlgorithmParameters.get_s_boxes[number][row.ord][column].chr
    end

    def self.affect_with_feitsel_permutation(block)
      permutated_block = block
      ind = 1
      DES::AlgorithmParameters.get_feitsel_permutation.each do |_|
        bit = get_bit_by_number(_, block)
        permutated_block = set_bit_by_number(ind, bit, permutated_block)
        ind += 1
      end
      permutated_block
    end

    def self.affect_with_inverse_permutation(block)
      permutated_block = block
      ind = 1
      DES::AlgorithmParameters.get_inverse_permutation.each do |_|
        bit = get_bit_by_number(_, block)
        permutated_block = set_bit_by_number(ind, bit, permutated_block)
        ind += 1
      end
      permutated_block
    end
  end
end
