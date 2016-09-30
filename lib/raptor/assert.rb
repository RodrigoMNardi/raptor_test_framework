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