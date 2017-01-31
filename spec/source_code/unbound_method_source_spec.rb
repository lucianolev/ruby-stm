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
def class_say
  @internal_var = "hello"
  local_var = @internal_var
  puts(local_var)
end
    CODE

    expect(UnboundMethodSourceCode.new(SomeClass.method(:class_say).unbind).to_s).to eq(expected_expression_src.gsub(/\n\z/, ''))
  end

  it 'should get the source of attr_* methods def inside a class' do
    class SomeClass
      attr_accessor :ivar
      attr_reader :ivar_reader
      attr_writer :ivar_writer

      def initialize
        @ivar_reader = 1
      end
    end

    ivar_read_method = <<-CODE
def ivar
  @ivar
end
    CODE

    ivar_assign_method = <<-CODE
def ivar=(value)
  @ivar = value
end
    CODE

    ivar_reader_read_method = <<-CODE
def ivar_reader
  @ivar_reader
end
    CODE

    ivar_writer_assign_method = <<-CODE
def ivar_writer=(value)
  @ivar_writer = value
end
    CODE

    expect(UnboundMethodSourceCode.new(SomeClass.instance_method(:ivar)).to_s).to eq(ivar_read_method.gsub(/\n\z/, ''))
    expect(UnboundMethodSourceCode.new(SomeClass.instance_method(:ivar=)).to_s).to eq(ivar_assign_method.gsub(/\n\z/, ''))
    expect(UnboundMethodSourceCode.new(SomeClass.instance_method(:ivar_reader)).to_s).to eq(ivar_reader_read_method.gsub(/\n\z/, ''))
    expect(UnboundMethodSourceCode.new(SomeClass.instance_method(:ivar_writer=)).to_s).to eq(ivar_writer_assign_method.gsub(/\n\z/, ''))
  end

end