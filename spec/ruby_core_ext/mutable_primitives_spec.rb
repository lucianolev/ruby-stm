require 'rspec'
require_relative '../../src/ruby_core_ext/module_extensions/mutable_primitives/all'

describe 'Mutable primitives' do
  it 'should mark all instances as mutable primitives when setting mutable_primitive_instances?'

  it 'should mark specific instance methods as primitives when sending mutable_primitives with specific method names' do
    class TestClass2
      def test_method1
      end

      def test_method2
      end

      alias_method :test_method3, :test_method2

      mutable_primitives :test_method1, :test_method3
    end

    expect([:test_method1, :test_method3].all? { |meth|
      TestClass2.is_a_mutable_primitive?(meth)
    }).to eq(true)
    expect(TestClass2.is_a_mutable_primitive?(:test_method2)).to eq(false)
  end
end