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

module Raptor
  module Assert
    def assert_greater_than(greater, less, params={})
      assert greater > less, params
    end

    def assert_equal_greater_than(threshold, found, params={})
      assert found >= threshold, params
    end

    def assert_less_equal_than(threshold, found, params={})
      assert found <= threshold, params
    end

    def assert_less_than(threshold, found, params={})
      assert found < threshold, params
    end

    def assert_equal(obj_one, obj_two, params={})
      assert obj_one == obj_two, params
    end

    def assert_not_equal(obj_one, obj_two, params={})
      assert obj_one != obj_two, params
    end

    def assert_is_empty?(array, params={})
      assert array.empty?, params
    end

    def assert_raises(*raises)
      if raises.last.to_s.match(/^\d+$/)
        @issue = raises.delete_at(raises.index(raises.last))
      end

      begin
        if block_given?
          yield
        end
        assert false, {}
      rescue *raises
        assert true, {}
      end
    end

    def assert_not_raise(params={})
      begin
        if block_given?
          yield
        end

        assert true, params
      rescue SignalException => error # Execution should finalize if a signal was received as SIGTERM
        raise error
      rescue Exception => error
        if params.has_key? :message
          params[:message] += "\nCould not raise a error, but #{error}"  
        else
          params[:message]  = "\nCould not raise a error, but #{error}"
        end  
        assert false, params
      end
    end

    def assert_match(string, reg_exp, params={})

      assert false, params unless string.is_a? String

      if string.match(reg_exp)
        assert true, params
      else
        assert false, params
      end
    end

    def assert_not_match(string, reg_exp, params={})
      assert false, params unless string.is_a? String

      if string.match(reg_exp)
        assert false, params
      else
        assert true, params
      end
    end

    def assert_not_empty?(obj, params={})
      assert !obj.empty?, params
    end

    def assert_empty?(obj, params={})
      assert obj.empty?, params
    end

    def assert_true(obj, params={})
      assert obj, params 
    end

    def assert_false(obj, params={})
      assert !obj, params
    end

    def assert_class(expect, obj, params={})
      assert obj.kind_of? expect, params
    end

    def assert_in_delta(delta, expected, value, params={})
      top = expected + delta
      bottom = expected - delta
      if value > top or value < bottom
        assert false, params
      else
        assert true, params
      end
    end

    def assert_include?(expected, value, params={})
      assert expected.include? value, params
    end
  end
end