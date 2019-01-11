require 'academic_benchmarks/api/constants'
require 'academic_benchmarks/api/standards'

module AcademicBenchmarks
  module Api
    class Handle
      include HTTParty

      attr_accessor :partner_id, :partner_key

      attr_reader :user_id # user_id writer is defined below

      base_uri AcademicBenchmarks::Api::Constants.base_url

      # Allows the user to initialize from environment variables
      def self.init_from_env
        partner_id  = partner_id_from_env
        partner_key = partner_key_from_env

        if !partner_id.present? || !partner_key.present?
          pidstr = !partner_id.present? ?
            AcademicBenchmarks::Api::Constants.partner_id_env_var : ""
          pkystr = !partner_key.present? ?
            AcademicBenchmarks::Api::Constants.partner_key_env_var : ""
          raise StandardError.new(
            "Missing environment variable(s): #{[pidstr, pkystr].join(', ')}"
          )
        end

        new(
          partner_id: partner_id,
          partner_key: partner_key,
          user_id: user_id_from_env
        )
      end

      def initialize(partner_id:, partner_key:, user_id: "")
        @partner_id = partner_id
        @partner_key = partner_key
        @user_id = user_id.to_s
      end

      def user_id=(user_id)
        @user_id = user_id.to_s
      end

      def related(guid:, fields: [])
        raise StandardError.new("Sorry, not implemented yet!")
      end

      def standards
        Standards.new(self)
      end

      def sync
        Sync.new(self)
      end

      def assets
        raise StandardError.new("Sorry, not implemented yet!")
      end

      def alignments
        raise StandardError.new("Sorry, not implemented yet!")
      end

      def topics
        raise StandardError.new("Sorry, not implemented yet!")
      end

      def special
        raise StandardError.new("Sorry, not implemented yet!")
      end

      def get_all( params:, path: )
        per_page = 100
        limit = params.delete( :limit )
        offset = params.delete( :offset ) || 0
        responses = []

        get_params = params.merge( auth_query_params )

        request_limit = [per_page, limit].compact.min
        first_page = request_page(
          query_params: get_params.merge( limit: request_limit, offset: offset ),
          path: path
        )
        responses << first_page

        total_count = first_page.dig("count")
        remaining_count = [total_count, limit].compact.min - request_limit
        offset += request_limit

        while remaining_count > 0
          request_limit = [remaining_count, per_page].min
          next_page = request_page(
            query_params: get_params.merge( limit: request_limit, offset: offset ),
            path: path
          )
          responses << next_page
          remaining_count -= request_limit
          offset += request_limit
        end
        responses
      end

      private

      def request_page( query_params:, path: )
        resp = self.class.get( path, query: query_params )

        if resp.code != 200
          raise RuntimeError.new(
            "Received response '#{resp.code}: #{resp.message}' requesting standards from Academic Benchmarks:"
          )
        end
        resp
      end

      def auth_query_params
        AcademicBenchmarks::Api::Auth.auth_query_params(
          partner_id: partner_id,
          partner_key: partner_key,
          expires: AcademicBenchmarks::Api::Auth.expire_time_in_2_hours,
          user_id: user_id
        )
      end

      def api_resp_to_array_of_standards(api_resp)
        api_resp.parsed_response["resources"].inject([]) do |retval, resource|
          retval.push(AcademicBenchmarks::Standards::Standard.new(resource["data"]))
        end
      end

      def self.partner_id_from_env
        ENV[AcademicBenchmarks::Api::Constants.partner_id_env_var]
      end

      def self.partner_key_from_env
        ENV[AcademicBenchmarks::Api::Constants.partner_key_env_var]
      end

      def self.user_id_from_env
        ENV[AcademicBenchmarks::Api::Constants.user_id_env_var]
      end
    end
  end
end
