require 'rspec'
require_relative '../ruby_core_ext/proc'

describe 'Transaction' do

  it 'Atomic should return the same value as a normal call for a simple object' do
    class Hello
      def say
        @internal_var = 'hello'
        local_var = @internal_var
        return local_var
      end
    end

    say_hello = Proc.new do
      hello = Hello.new
      hello.say
    end

    expect(say_hello.atomic).to eq(say_hello.call)
  end

  it 'Atomic should return the same value as a normal call for a simple, but modified, object' do
    class MyObject
      def initialize
        @internal_var = 1
      end

      def set_var(elem)
        @internal_var = elem
      end
    end

    obj_code = Proc.new do
      my_obj = MyObject.new
      my_obj.set_var(2)
      my_obj
    end

    expect(obj_code.atomic.instance_variables).to eq(obj_code.call.instance_variables)
  end

  it 'Atomic should return the same value as a normal call for an object with uses an array internally' do
    class MyList
      def initialize
        @internal_var = [1, 2, 3]
      end

      def set_elem(elem)
        local = 5
        @internal_var[1] = 3 + local
        @internal_var[0] = elem
      end
    end

    list_code = Proc.new do
      my_list = MyList.new
      my_list.set_elem(2)
      my_list
    end

    expect(list_code.atomic.instance_variables).to eq(list_code.call.instance_variables)
  end
end