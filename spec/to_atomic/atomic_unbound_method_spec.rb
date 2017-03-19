require 'rspec'
require_relative '../../src/to_atomic/atomic_unbound_method'

describe AtomicUnboundMethod do

  it 'should generate the atomic version of a method definition correctly' do
    a_class = Class.new do
      # noinspection RubyUnusedLocalVariable,RubyResolve
      def a_method
        myobj = MyObj.new
        local_var = 5
        @instance_var = 8
        another_local = @instance_var
        myobj.method_call
      end
    end

    expected_code = <<-CODE
def __atomic__a_method
  myobj = MyObj.__atomic__new
  local_var = 5
  self.__atomic__instance_variable_set(:@instance_var, 8)
  another_local = self.__atomic__instance_variable_get(:@instance_var)
  myobj.__atomic__method_call
end
    CODE
    expect(AtomicUnboundMethod.from(a_class.instance_method(:a_method)).source_code.to_s).to eq(expected_code.gsub(/\n\z/, ''))
  end

  it 'should generate the atomic version of a CLASS method definition correctly' do
    a_class = Class.new do
      # noinspection RubyUnusedLocalVariable
      def self.a_method
        a_var = 1
      end
    end
    expected_code = <<-CODE
def __atomic__a_method
  a_var = 1
end
    CODE
    expect(AtomicUnboundMethod.from(a_class.method(:a_method).unbind).source_code.to_s).to eq(expected_code.gsub(/\n\z/, ''))
  end

  if RUBY_ENGINE == 'rbx'
    it 'should not transform code inside Rubinius.asm blocks'

    it 'should consider variables inside Rubinius.privately blocks as variables defined out that block'

    it 'should not transform Rubinius compiler macros'

    it 'should remove Rubinius.primitive nodes' do
      a_class = Class.new do
        # noinspection RubyUnusedLocalVariable,RubyResolve
        def a_method
          Rubinius.primitive :a_primitive
          myobj = MyObj.new
          myobj.method_call
        end
      end

      expected_code = <<-CODE
def __atomic__a_method
  myobj = MyObj.__atomic__new
  myobj.__atomic__method_call
end
      CODE

      expect(AtomicUnboundMethod.from(a_class.instance_method(:a_method)).source_code.to_s).to eq(expected_code.gsub(/\n\z/, ''))
    end
  end
end