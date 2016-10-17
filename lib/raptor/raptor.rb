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
    @@suite[:setup]        = nil
    @@suite[:teardown]     = nil
    @@suite[:terminate]    = nil
    @@suite[:verification] = []
    @@suite[:context]      = []

    def self.output(message)
      @@logger.info(message)
    end

    def self.description(&block)
      @@suite[:description] = block
    end

    def self.setup(&block)
      @@suite[:setup] = ['setup', block]
    end

    def self.teardown(&block)
      @@suite[:teardown] = ['teardown', block]
    end

    def self.terminate(&block)
      @@suite[:terminate] = ['terminate', block]
    end

    def self.verification(name, &block)
      @@suite[:verification] << ["Verification #{name}", block]
    end

    def self.context(message, &block)
      @@suite[:context] = [@@suite[:verification].last.first, message]
      @@logger.info "Context: #{message}"

      yield block if block_given?
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

      self.call_method(:setup)

      @@suite[:verification].each do |name, block|
        begin
          self.print_header(name, 'STARTING')
          block.call
          self.print_header(name, 'FINISHING')

          if @@suite[:teardown]
            self.call_method(:teardown)
            self.call_method(:setup)
          end

        rescue Exception => error
          self.print_header(name, 'FINISHING')

          backtrace = error.backtrace.delete_if{|e| !e.match(/raptor/)}
          @reporter.add_fatal_error("#{error.class} - #{error.message}\n#{backtrace.join("\n")}")
          return
        end
      end
    end

    def self.cleanup
      @@names = []
    end

    def self.logger=(logger)
      @@logger = logger
    end

    private

    def self.call_method(name)
      if @@suite[name]
        self.print_header(name, 'STARTING')
        begin
          @@logger.info @@suite[name][1].call

          self.print_header(name, 'FINISHING')
        rescue Exception => error
          self.print_header(name, 'FINISHING')

          backtrace = error.backtrace.delete_if{|e| !e.match(/raptor/)}
          @reporter.add_fatal_error("#{error.class} - #{error.message}\n#{backtrace.join("\n")}")
          return
        end
      end
    end

    def self.print_header(name, str_fns)
      message = "------- #{str_fns} #{name} -------"
      @@logger.info '-' * message.size
      @@logger.info message
      @@logger.info '-' * message.size
    end

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
          msg         = ''
          issues      = ''
          assert      = ''
          args        = ''
          result      = "\nResult        : #{(bool)? 'Passed' : 'Failed'}"
          issues      = "\nPossible bugs : #{params[:issues]}"  if params.is_a? Hash and params.has_key? :issues
          msg         = "\nMessage       : #{params[:message]}" if params.is_a? Hash and params.has_key? :message
          assert      = "\nAssert        : #{params[:assert]}"  if params.is_a? Hash and params.has_key? :assert
          args        = "\nParameter(s)  : #{params[:args]}"    if params.is_a? Hash and params.has_key? :args

          if bool
            @reporter.add_passed
          else
            @reporter.add_failed
          end

          @@logger.info "#{result}#{assert}#{args}#{issues}#{msg}"
        end
      end
    end
  end
end