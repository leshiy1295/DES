#!/usr/bin/env euby

require_relative 'src/encoder'
require_relative 'src/decoder'

def get_block_to_encode
  ENV['BLOCKTOENCODE']
end

def get_block_to_decode
  ENV['BLOCKTODECODE']
end

task :encode do
    block = get_block_to_encode
    DES::Encoder.encode(block)
end

task :decode do
    block = get_block_to_decode
    DES::Decoder.decode(block)
end

task :help do
  puts 'Hello! That program can be used for encoding and decoding 64-bit block with DES algorithm.'
  puts 'To encode block you should place it to env-variable BLOCKTOENCODE and call encode task with "rake encode".'
  puts 'To decode block you should place it to env-variable BLOCKTODECODE and call encode task with "rake decode".'
end

task :default => :help
