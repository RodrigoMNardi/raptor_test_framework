#
#  Copyright (c) 2016, Rodrigo Mello Nardi
#  All rights reserved.
#
#  Redistribution and use in source and binary forms, with or without
#  modification, are permitted provided that the following conditions are met:
#
#  1. Redistributions of source code must retain the above copyright notice, this
#     list of conditions and the following disclaimer.
#  2. Redistributions in binary form must reproduce the above copyright notice,
#     this list of conditions and the following disclaimer in the documentation
#     and/or other materials provided with the distribution.
#
#  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
#  ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
#  WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
#  DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR
#  ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
#  (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
#  LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
#  ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
#  (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
#  SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
#
#  The views and conclusions contained in the software and documentation are those
#  of the authors and should not be interpreted as representing official policies,
#  either expressed or implied, of the FreeBSD Project.
#

require_relative 'reporter'
require_relative '../raptor/raptor'
require_relative '../../lib/connection/control_connection'

module Factory
  class Builder
    def initialize(profile)
      @profile = profile

      if profile.has_key? :test
        return     if profile[:test].match(/\.[rb]~/)
        return unless profile[:test].match(/\.rb/)

        puts "*"*80
        puts profile[:test]
        puts "*"*80

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
        puts @reporter.display
      end
    end
  end
end
