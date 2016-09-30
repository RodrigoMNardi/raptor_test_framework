$:.unshift "#{File.dirname(__FILE__)}/../../"

require 'lib/factory/reporter'
require 'lib/raptor/raptor'

module Factory
  class Builder
    def initialize(profile)
      @profile = profile

      if profile.has_key? :test
        return     if profile[:test].match(/\.[rb]~/)
        return unless profile[:test].match(/\.rb/)

        require "#{File.dirname(__FILE__)}/../../" + profile[:test]
      end
    end

    def run
      ObjectSpace.each_object do |test|
        next unless test.is_a? Class
        next if test.to_s.match(/Factory::Builder/i)
        next unless test < Raptor::TestSuite
        if @profile.has_key? :name
          next unless test.to_s.match(/#{@profile[:name]}/i)
        end

        @reporter = Factory::Reporter.new(test.to_s)
        test.add_report(@reporter)
        test.run
        @reporter.display
      end
    end
  end
end