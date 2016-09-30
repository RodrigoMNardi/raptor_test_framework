module Factory
  class Reporter
    def initialize(test_name)
      @test_name = test_name
      @results   = {passed: 0, failed: 0, warn: 0, fatal_error: 0, total: 0}
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

    def add_fatal_error
      @results[:fatal_error] += 1
    end

    def display
      puts @results.inspect
    end
  end
end