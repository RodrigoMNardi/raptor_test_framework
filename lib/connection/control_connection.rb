require 'singleton'
require 'yaml'

require_relative '../../lib/protocols/grpc/rip'

module Control
  class Connection
    include Singleton

    def initialize
      @config   = YAML.load_file("#{File.dirname(__FILE__)}/../../configuration.yml")
      @machines = []
      if @config.key? 'machines' and @config['machines'].is_a? Array
        @config['machines'].each do |machine_cfg|
          @machines << Machine.new(machine_cfg)
        end
      end
    end

    #
    # Search for rip router with the desired features.
    # Parameters:
    # * local: boolean (Defalt: nil) - Search for a local rip router in config file.
    #   - true  - Local machine (your pc)
    #   - false - Remote / VM machine
    #   - nil   - anyone
    # * features: array * Mandatory
    #   - :grpc - Desired router must have gRPC port enable
    #   - :telnet - Desired router must have telnet port enable
    #   - :ssh - Desired router must have ssh port enable
    # * type: symbol * Mandatory
    #   - Equipment type as :pc or :vagrant
    #
    def get_router(**mode)
      machine =
        @machines.select do |machine|
          machine.local?(mode[:local] | nil) and
            machine.features? mode[:features] and
            machine.type? mode[:type]
        end.first
      machine
    end

    private

    def select_grpc
      if @config.key? 'vagrant'
        @config.key
      end
    end
  end

  class Machine
    def initialize(config)
      @name = config.keys.first
      @conf = config.values.first
    end

    def features
      (@conf.key? 'features')? @conf['features'] : []
    end

    def local?(status)
      return true if status.nil?
      return false unless @conf.key? :local
      @conf[:local] == status
    end


    def type?(t)
      return false unless @conf.key? :type
      @conf[:type] == t
    end

    def features?(fts)
      return false unless @conf.key? :features

      if fts.is_a? String or fts.is_a? Symbol
        return @conf[:features].include? fts
      end

      if fts.is_a? Array
        fts.delete_if{|f| @conf[:features].include? f}
        (fts.empty?)? true : false
      end
    end

    def rip
      return if !@conf.key? :address and !@conf.key? :grpc and !@conf[:grpc].key? :rip
      channel_args = { "grpc.max_send_message_length"    => -1,
                       "grpc.max_receive_message_length" => -1 }
      GRPC::FRR::Rip.new("#{@conf[:address]}:#{@conf[:grpc][:rip]}", channel_args: channel_args)
    end
  end
end
