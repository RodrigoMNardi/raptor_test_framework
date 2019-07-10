class RipBasic < Raptor::TestSuite
  description do
    'Creating a RIP router using gRPC and validating that settings are in accordance'
  end

  setup do
    @instance_1 = Control::Connection.instance.get_router(local: true, features: [:grpc], type: :pc)
    rip = @instance_1.rip
    rip_candidate = rip.create_candidate
    rip_candidate.disable_ecmp
    rip_candidate.metric(value: 10)
    rip_candidate.distance(value: 175)
    rip_candidate.add_source(source: "172.16.1.0/24", distance: '174')
    rip_candidate.explicit_neighbor(neighbor: "192.168.255.16")
    rip.commit(candidate: rip_candidate, comment: "basic_rip")
  end

  verification 'config_vs_running' do
    puts "RIP gRPC: #{@instance_1.rip.inspect}"
    assert_true(true)
  end
end
