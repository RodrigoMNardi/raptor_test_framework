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

module Factory
  class Reporter
    def initialize(test_name)
      @test_name = test_name
      @results   = {passed: 0.0, failed: 0.0, warn: 0, fatal_error: 0, total: 0}
    end

    def count_assert
      @results[:total] += 1
    end

    def add_passed
      @results[:passed] += 1
    end

    def add_failed
      @results[:failed] += 1
    end

    def add_warn
      @results[:warn] += 1
    end

    def add_fatal_error(error)
      @results[:fatal_error] += 1
      @fatal_error = error
    end

    def raw
      puts @results.inspect
    end

    def display
      "
Test    : #{@test_name}
Asserts : #{@results[:total]}
Result  :
          Passed      : #{((@results[:passed] / @results[:total]) * 100).round(2)}%
          Failed      : #{((@results[:failed] / @results[:total]) * 100).round(2)}%
          Warn        : #{@results[:warn]}
          Fatal Error : #{@results[:fatal_error]}
"
    end
  end
end