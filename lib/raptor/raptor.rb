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