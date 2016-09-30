$:.unshift "#{File.dirname(__FILE__)}/../../"

require 'logger'
require 'lib/raptor/assert'
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

    def self.run
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
          @@logger.info "==> Assert: #{bool}#{msg} #{issues}"
        end
      end

      if @@suite[:description]
        @@suite[:description].call
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
  end
end