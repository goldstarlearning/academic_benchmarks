require 'academic_benchmarks/api/auth'
require 'academic_benchmarks/api/constants'

module AcademicBenchmarks
  module Api
    class Sync
      def initialize(handle)
        @handle = handle
      end

      def changes_since( date, resource: )
        responses = handle.get_all(
          params: {since: date, resource: resource},
          path: "/sync"
        )

        responses.map(&:parsed_response)
      end

      private
      def handle; @handle; end
    end
  end
end
