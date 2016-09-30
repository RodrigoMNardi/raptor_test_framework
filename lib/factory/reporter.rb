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