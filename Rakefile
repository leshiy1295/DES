#!/usr/bin/env ruby

require_relative 'src/encoder'
require_relative 'src/decoder'
require_relative 'src/algorithm_parameters'

def get_block_to_encode
  DES::AlgorithmParameters.get_block_to_encode
end

def get_block_to_decode
  DES::AlgorithmParameters.get_block_to_decode
end

task :create_round_keys do
  DES::AlgorithmHelper.create_round_keys
end

task :encode => :create_round_keys do
    block = get_block_to_encode
    DES::Encoder.encode(block)
end

task :encode_and_decode => :encode do
    block = get_block_to_decode
    DES::Decoder.decode(block)
end

task :help do
  puts 'Hello! That program can be used for encoding and decoding 64-bit block with DES algorithm.'
  puts 'To encode block you should place it to algorithm_parameters.rb and call encode task with "rake encode".'
  puts 'To encode and decode block you should place it to algorithm_parameters.rb and call encode task with "rake encode_and_decode".'
end

task :default => :help
