require 'academic_benchmarks/lib/inst_vars_to_hash'

module AcademicBenchmarks
  module Standards
    class Section
      include InstVarsToHash

      attr_accessor :guid, :descr, :children, :seq

      alias_method :description, :descr

      def self.from_hash(hash)
        self.new(descr: hash["descr"], guid: hash["guid"], seq: hash["seq"] )
      end

      def initialize(guid:, descr:, children: [], seq:)
        @guid = guid
        @descr = descr
        @children = children
        @seq = seq
      end
    end
  end
end
