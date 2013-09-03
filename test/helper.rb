# encoding: utf-8

require 'minitest'
require 'minitest/autorun'
require 'yard'
require 'nanoc-core'
require 'nanoc-linking'

# FIXME de-duplicate this
def assert_examples_correct(object)
  P(object).tags(:example).each do |example|
    # Classify
    lines = example.text.lines.map do |line|
      [ line =~ /^\s*# ?=>/ ? :result : :code, line ]
    end

    # Join
    pieces = []
    lines.each do |line|
      if !pieces.empty? && pieces.last.first == line.first
        pieces.last.last << line.last
      else
        pieces << line
      end
    end
    lines = pieces.map { |p| p.last }

    # Test
    b = binding
    lines.each_slice(2) do |pair|
      actual_out   = eval(pair.first, b)
      expected_out = eval(pair.last.match(/# ?=>(.*)/)[1], b)

      assert_equal expected_out, actual_out,
        "Incorrect example:\n#{pair.first}"
    end
  end
end
