require 'academic_benchmarks/lib/inst_vars_to_hash'

module AcademicBenchmarks
  module Standards
    class Course
      include InstVarsToHash

      attr_accessor :guid, :description, :seq

      alias_method :descr, :description

      def self.from_hash(hash)
        self.new(description: hash["descr"], guid: hash["guid"], seq: hash["seq"])
      end

      def initialize(guid:, description:, seq:)
        @guid = guid
        @description = description
        @seq = seq
      end
    end
  end
end
