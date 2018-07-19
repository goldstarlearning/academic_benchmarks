require 'academic_benchmarks/lib/inst_vars_to_hash'

module AcademicBenchmarks
  module Standards
    class Grade
      include InstVarsToHash

      attr_accessor :high, :low, :seq

      def self.from_hash(hash)
        self.new(high: hash["high"], low: hash["low"], seq: hash["seq"])
      end

      def initialize(high:, low:, seq:)
        @high = high
        @low = low
        @seq = seq
      end
    end
  end
end
