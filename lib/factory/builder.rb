$:.unshift "#{File.dirname(__FILE__)}/../../"

require 'lib/raptor/raptor'

module Factory
  class Builder
    def initialize(profile)
      if profile.has_key? :test
        return     if profile[:test].match(/\.[rb]~/)
        return unless profile[:test].match(/\.rb/)

        require "#{File.dirname(__FILE__)}/../" + profile[:test]
      end

      run
    end

    def run
      ObjectSpace.each_object do |test|
        next unless test.is_a? Class
        next unless test.to_s.match(/Raptor::TestSuite/i)

        test.run
      end
    end

    private


  end
end

Factory::Builder.new({test: 'tests/example.rb'})