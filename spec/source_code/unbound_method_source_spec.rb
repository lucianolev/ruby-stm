require 'rspec'
require_relative '../../src/source_code/unbound_method_source_code'

describe UnboundMethodSourceCode do

  it 'should get the source of a method def inside a class' do
    class SomeClass
      def say
        @internal_var = 'hello'
        local_var = @internal_var
        puts local_var
      end
    end

    expected_expression_src = <<-CODE
def say
  @internal_var = "hello"
  local_var = @internal_var
  puts(local_var)
end
    CODE

    expect(UnboundMethodSourceCode.new(SomeClass.instance_method(:say)).to_s).to eq(expected_expression_src.gsub(/\n\z/, ''))
  end

  it 'should get the source of a class method def inside a class' do
    class SomeClass
      def self.class_say
        @internal_var = 'hello'
        local_var = @internal_var
        puts local_var
      end
    end

    expected_expression_src = <<-CODE
def self.class_say
  @internal_var = "hello"
  local_var = @internal_var
  puts(local_var)
end
    CODE

    expect(UnboundMethodSourceCode.new(SomeClass.method(:class_say)).to_s).to eq(expected_expression_src.gsub(/\n\z/, ''))
  end

end