$:.unshift "#{File.dirname(__FILE__)}/../../"

require 'logger'
require 'lib/raptor/assert'
require 'lib/factory/reporter'
require 'lib/factory/screen'

module Raptor
  class TestSuite
    include Raptor::Assert

    @@logger               = Factory::Screen.new
    @@suite                = {}
    @@suite[:description]  = nil
    @@suite[:configure]    = nil
    @@suite[:verification] = []
    @@suite[:context]      = []

    def self.logger
      @@logger
    end

    def self.description(&block)
      @@suite[:description] = block
    end

    def self.configure(&block)
      @@suite[:configure] = ['configure', block]
    end

    def self.verification(name, &block)
      @@suite[:verification] << ["Verification #{name}", block]
    end

    def self.context(message, &block)
      @@suite[:context] = [@@suite[:verification].last.first, message]
      @@logger.info "Context: #{message}"

      yield if block_given?
    end

    def self.add_report(reporter)
      @reporter = reporter
    end

    def self.run
      create_assert_environment

      if @@suite[:description]
        total_asserts(@@suite[:description].source_location.first)
        @@suite[:description].call
      else
        raise 'Description should be exist'
      end

      if @@suite[:configure]
        @@logger.info @@suite[:configure][0]
        @@logger.info @@suite[:configure][1].call
      end

      @@suite[:verification].each do |name, block|
        @@logger.info name
        block.call
      end
    end

    def self.cleanup
      @@names = []
    end

    private

    def self.total_asserts(location)
      File.open(location, 'r').each_line do |line|
        if line.match(/^(\t|\s)*assert/)
          @reporter.count_assert
        end
      end
    end

    def self.create_assert_environment
      self.extend(Raptor::Assert)

      Raptor::Assert.class_eval do
        define_method(:logger) do
          @@logger
        end
      end

      Raptor::Assert.class_eval do
        define_method(:assert) do |bool, params|
          msg    = ''
          issues = ''
          issues = " Possible issues: #{params[:issues]}" if params.is_a? Hash and params.has_key? :issues
          msg    = " - #{params[:message]}"               if params.is_a? Hash and params.has_key? :message

          if bool
            @reporter.add_passed
          else
            @reporter.add_failed
          end

          @@logger.info "==> Assert: #{bool}#{msg} #{issues}"
        end
      end
    end
  end
end