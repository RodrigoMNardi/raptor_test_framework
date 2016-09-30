require 'logger'

module Factory
  class Screen
    def initialize
      @logger = Logger.new($stdout)
    end

    def info(message)
      @logger.info message
    end
  end
end