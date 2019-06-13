#
# Copyright (c) 2019 Rodrigo Nardi
#
# Permission to use, copy, modify, and distribute this software for any
# purpose with or without fee is hereby granted, provided that the above
# copyright notice and this permission notice appear in all copies.
#
# THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES
# WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF
# MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR
# ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES
# WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN AN
# ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF
# OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.
#
require_relative '../../../lib/grpc/northbound'

module GRPC
  module FRR
    class Rip < Northbound
      def initialize(host, options, security = :this_channel_is_insecure)
        @push       = "/frr-ripd:ripd"
        super
      end

      def get
        request = Frr::GetRequest.new
        request.type = :STATE
        request.encoding = :JSON
        request.path.push(@push)

        @stub.get(request).each do |r|
          puts "  timestamp: #{r.timestamp} (#{Time.at(r.timestamp).to_datetime})"
          print_datatree(r.data)
        end
      end

      def execute(path)
        request = Frr::ExecuteRequest.new
        request.path = path
        response = @stub.execute(request)
        response.output.each do |o|
          puts "  #{o.path}: #{o.value}"
        end
      end

      def transactions
        response = @stub.list_transactions(Frr::ListTransactionsRequest.new)
        response.map do |t|
          puts "  #{t.id} | #{t.client} | #{t.date} | #{t.comment}"
        end
      end

      def transaction(id)
        req = Frr::GetTransactionRequest.new(transaction_id: id, encoding: :JSON, with_defaults: false)
        response = @stub.get_transaction(req)
        print_datatree(response.config)
      end

      def create_candidate
        response = @stub.create_candidate(Frr::CreateCandidateRequest.new)
        RipCandidate.new(response.candidate_id)
      end

      def update_candidate(id)
        begin
          req      = Frr::UpdateCandidateRequest.new(candidate_id: id)
          @stub.update_candidate(req)
        rescue GRPC::NotFound
          puts "Candidate configuration not found"
        end
      end

      def delete_candidate(id)
        begin
          req = Frr::DeleteCandidateRequest.new(candidate_id: id)
          @stub.delete_candidate(req)
        rescue GRPC::NotFound
          puts "Candidate configuration not found"
        end
      end

      def commit(**params)
        load_2_candidate(params[:candidate].id, params[:candidate].config, :REPLACE)

        begin
          request              = Frr::CommitRequest.new
          request.candidate_id = params[:candidate].id
          request.phase        = params[:phase]   || :ALL
          request.comment      = params[:comment] || "AUTOMATIC"

          response = @stub.commit(request)
          puts "  transaction_id: #{response.transaction_id}"
          response.transaction_id
        rescue GRPC::Aborted
          puts "No configuration changes detected"
        end
      end

      def operational_states
        request = Frr::GetRequest.new
        request.type = :STATE
        request.encoding = :JSON
        request.path.push("#{@push}/instance[vrf='default']/state/neighbors")

        @stub.get(request).each do |r|
          puts "  timestamp: #{r.timestamp} (#{Time.at(r.timestamp).to_datetime})"
          print_datatree(r.data)
        end
      end

      private

      def load_2_candidate(candidate_id, data, mode)
        request               = Frr::LoadToCandidateRequest.new
        request.candidate_id  = candidate_id
        request.type          = mode

        config                = Frr::DataTree.new
        config.encoding       = :JSON
        config.data           = data.to_json

        puts config.inspect
        request.config = config

        @stub.load_to_candidate(request)
      end
    end

    class RipCandidate
      attr_reader :id, :config

      def initialize(id)
        @id = id
        @config = {"frr-ripd:ripd": {"instance": [{"vrf": 'default'}]}}
      end

      def enable_ecmp
        @config[:"frr-ripd:ripd"][:"instance"][0]["allow-ecmp"] = true
      end

      def disable_ecmp
        puts  @config.inspect
        @config[:"frr-ripd:ripd"][:"instance"][0]["allow-ecmp"] = false
      end

      def explicit_neighbor(**params)
        unless @config[:"frr-ripd:ripd"][:"instance"][0].has_key? "explicit-neighbor"
          @config[:"frr-ripd:ripd"][:"instance"][0]["explicit-neighbor"] = []
        end
        @config[:"frr-ripd:ripd"][:"instance"][0]["explicit-neighbor"] << params[:neighbor]
      end

      def enable_information_originate(vrf='default')
        @config[:"frr-ripd:ripd"][:"instance"][0]["default-information-originate"] = true
      end

      def disable_information_originate(vrf='default')
        @config[:"frr-ripd:ripd"][:"instance"][0]["default-information-originate"] = false
      end

      def metric(**params)
        unless (1..16).include? params[:value]
          raise "Invalid value range. Expected a value between 1 to 255."
        end

        @config[:"frr-ripd:ripd"][:"instance"][0]["default-metric"] = params[:value].to_s
      end

      def distance(**params)
        unless (1..255).include? params[:value].to_i
          raise "Invalid value range. Expected a value between 1 to 255."
        end

        @config[:"frr-ripd:ripd"][:"instance"][0]["distance"] = params[:value].to_s
      end

      def add_source(**params)
        @config[:"frr-ripd:ripd"][:"instance"][0]["distance"] = {source:
                                                                     [{prefix: params[:source],
                                                                       distance: params[:distance]}
                                                                     ]}
      end

      def network(**params)
        unless @config[:"frr-ripd:ripd"][:"instance"][0].key? "network"
          @config[:"frr-ripd:ripd"][:"instance"][0]["network"] = []
        end
        @config[:"frr-ripd:ripd"][:"instance"][0]["network"] << params[:prefix]
      end

      def interface(**params)
        raise "Invalid interface must be between 1 to 16" unless (1..16).include? params[:interface]
        unless @config[:"frr-ripd:ripd"][:"instance"][0].key? "interface"
          @config[:"frr-ripd:ripd"][:"instance"][0]["interface"] = []
        end
        @config[:"frr-ripd:ripd"][:"instance"][0]["interface"] << params[:interface]
      end

      def access_list(**params)
        @config[:"frr-ripd:ripd"][:"instance"][0]["offset-list"] = [
            {
                "interface":   params["interface"]   || '*',
                "direction":   params["direction"]   || 'in',
                "access-list": params["access_list"] || 'undefined',
                "metric":      params["metric"]      || 4
            }
        ]
      end

      def passive_default(**params)
        @config[:"frr-ripd:ripd"][:"instance"][0]["passive-default"] = params["status"] || false
      end

      def passive_interface(**params)
        unless (0..16).include? params[:interface]
          raise "Invalid value range. Expected a interface between 0 to 16."
        end

        if @config[:"frr-ripd:ripd"][:instance][0]["passive-default"]
          unless @config[:"frr-ripd:ripd"][:instance][0].key? "non-passive-interface"
            @config[:"frr-ripd:ripd"][:instance][0]["non-passive-interface"] = []
          end
          @config[:"frr-ripd:ripd"][:instance][0]["non-passive-interface"] << params[:interface] || 0
          return
        end

        unless @config[:"frr-ripd:ripd"][:instance][0].key? "passive-interface"
          @config[:"frr-ripd:ripd"][:instance][0]["passive-interface"] = []
        end
        @config[:"frr-ripd:ripd"][:instance][0]["passive-interface"] << params[:interface] || 0
      end

      def redistribute(**params)
        if params.key? :protocol and params[:protocol].match(/^rip$/n)
          raise "Protocol should be different from RIP"
        end

        if params.key? :route_map and params[:route_map] < 1
          raise "Route must be greater than or equal to 1"
        end

        if params.key? :metric and !(0..16).include? params[:metric]
          raise "Invalid value range. Expected a interface between 0 to 16."
        end

        unless @config[:"frr-ripd:ripd"][:instance][0].key? :redistribute
          @config[:"frr-ripd:ripd"][:instance][0][:redistribute] = []
        end

        @config[:"frr-ripd:ripd"][:instance][0][:redistribute] << {
            protocol:    params[:protocol],
            "route-map": params[:route_map] || 1,
            metric:      params[:metric]    || 0,
        }
      end

      def static_route(**params)
        unless @config[:"frr-ripd:ripd"][:"instance"][0].key? "static-route"
          @config[:"frr-ripd:ripd"][:"instance"][0]["static-route"] = []
        end
        @config[:"frr-ripd:ripd"][:"instance"][0]["static-route"] << params[:route]
      end

      def timers(**params)
        @config[:"frr-ripd:ripd"][:"instance"][0]["timers"] = {
            "flush-interval":    params[:flush_interval]    || 120,
            "holddown-interval": params[:holddown_interval] || 180,
            "update-interval":   params[:update_interval]   || 30
        }
      end

      def rip_version(**params)
        if params.key? :receive and params.key? :send
          unless params[:receive] == params[:send] or (params[:receive] == '1-2' and params[:send] == '2')
            raise "RIP version must satisfy same conditions: receive == send or receive == '1-2' and send == '2'"
          end
        end

        @config[:"frr-ripd:ripd"][:"instance"][0]["version"] = {
            receive: params[:receive] || '1-2',
            send:    params[:send]    || '2',
        }
      end
    end
  end
end
