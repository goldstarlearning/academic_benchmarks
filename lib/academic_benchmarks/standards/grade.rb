require 'academic_benchmarks/lib/inst_vars_to_hash'

module AcademicBenchmarks
  module Standards
    class Grade
      include InstVarsToHash

      attr_accessor :code, :seq

      def self.from_hash(hash)
        self.new(code: hash["code"], seq: hash["seq"])
      end

      def initialize(code:, seq:)
        @code = code
        @seq = seq
      end
    end
  end
end
