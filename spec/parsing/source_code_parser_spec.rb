require 'rspec'
require_relative '../../parsing/source_code_parser'

describe SourceCodeParser do

  it 'should get the source of multi-lined Proc definition' do
    say_hello = Proc.new do
      hello = Hello.new
      hello.say
    end

    expected_expression_src = <<-CODE
hello = Hello.new
hello.say
    CODE

    expect(SourceCodeParser.new.get_proc_source_code(say_hello)).to eq(expected_expression_src.gsub(/\n\z/, ''))
  end

  it 'should get the source of single Proc definition which uses "{ }", in a specific line' do
    say_hello_2 = Proc.new { hello = Hello.new; hello.say }

    expected_expression_src = <<-CODE
hello = Hello.new
hello.say
    CODE

    expect(SourceCodeParser.new.get_proc_source_code(say_hello_2)).to eq(expected_expression_src.gsub(/\n\z/, ''))
  end

  it 'should get the source of two-line Proc definition, with a break after "=", in a specific line' do
    say_hello_3 =
        Proc.new do
          hello = Hello.new; hello.say
        end

    expected_expression_src = <<-CODE
hello = Hello.new
hello.say
    CODE

    expect(SourceCodeParser.new.get_proc_source_code(say_hello_3)).to eq(expected_expression_src.gsub(/\n\z/, ''))
  end

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

    expect(SourceCodeParser.new.get_method_definition(SomeClass.instance_method(:say))).to eq(expected_expression_src.gsub(/\n\z/, ''))
  end

end