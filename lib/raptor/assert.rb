#
#  Copyright (c) 2017, Rodrigo Mello Nardi
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
      params[:assert] = 'assert_greater_than'
      params[:args]        = "#{greater} > #{less}"
      assert greater > less, params
    end

    def assert_equal_greater_than(limit, found, params={})
      params[:assert] = 'assert_equal_greater_than'
      params[:args]        = "#{found} >= #{limit}"
      assert found >= limit, params
    end

    def assert_less_equal_than(limit, found, params={})
      params[:assert] = 'assert_less_equal_than'
      params[:args]        = "#{found} <= #{limit}"
      assert found <= limit, params
    end

    def assert_less_than(limit, found, params={})
      params[:assert] = 'assert_less_equal_than'
      params[:args]        = "#{found} <= #{limit}"
      assert found < limit, params
    end

    def assert_equal(one, two, params={})
      params[:assert] = 'assert_less_equal_than'
      params[:args]        = "#{one} == #{two}"
      assert one == two, params
    end

    def assert_not_equal(one, two, params={})
      params[:assert] = 'assert_not_equal'
      params[:args]        = "#{one} != #{two}"
      assert one != two, params
    end

    def assert_raises(*raises_list)
      params[:assert] = 'assert_raises'
      params[:args]        = "#{raises_list.inspect}"

      if raises_list.last.to_s.match(/^\d+$/)
        @issue = raises_list.delete_at(raises_list.index(raises_list.last))
      end

      begin
        if block_given?
          yield
        end
        assert false, {}
      rescue *raises_list
        assert true, {}
      end
    end

    def assert_not_raise(params={})
      params[:assert] = 'assert_not_raise'
      params[:args]        = ''

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
      params[:assert] = 'assert_match'
      params[:args]        = "#{string.inspect}.match(#{reg_exp})"

      raise 'Invalid type - Used only for string' unless string.is_a? String

      if string.match(reg_exp)
        assert true, params
      else
        assert false, params
      end
    end

    def assert_not_match(string, reg_exp, params={})
      params[:assert] = 'assert_not_match'
      params[:args]        = "#{string.inspect}.match(#{reg_exp})"

      raise 'Invalid type - Used only for string' unless string.is_a? String

      if string.match(reg_exp)
        assert false, params
      else
        assert true, params
      end
    end

    def assert_is_empty?(array, params={})
      params[:assert] = 'assert_is_empty?'
      params[:args]        = "#{array.inspect}"
      assert array.empty?, params
    end

    def assert_not_empty?(obj, params={})
      params[:assert] = 'assert_not_empty?'
      params[:args]        = "#{obj.inspect}"

      assert !obj.empty?, params
    end

    def assert_class(expect, obj, params={})
      params[:assert] = 'assert_class'
      params[:args]        = "#{expect} == #{obj}"

      assert obj.kind_of? expect, params
    end

    def assert_in_delta(found_point, middle_point, delta, params={})
      params[:assert] = 'assert_in_delta'

      raise 'Invalid type - Used only for integer' unless found_point.is_a? Integer  or
                                                          middle_point.is_a? Integer or
                                                          delta.is_a? Integer

      top    = middle_point + delta
      bottom = middle_point - delta
      params[:args]        = "#{found_point} > #{top} or #{found_point} < #{bottom}"

      if found_point > top or found_point < bottom
        assert false, params
      else
        assert true, params
      end
    end

    def assert_include?(expected, found, params={})
      params[:assert] = 'assert_in_delta'
      params[:args]        = "#{expected}.include? #{found}"

      assert expected.include? found, params
    end

    def assert_true(found, params={})
      params[:assert] = 'assert_true'
      params[:args]        = "#{found}"

      assert found, params
    end

    def assert_false(found, params={})
      params[:assert] = 'assert_false'
      params[:args]        = "#{found}"

      assert !found, params
    end
  end
end