require 'rspec'
require_relative '../../src/source_code/proc_source_code'

describe ProcSourceCode do

  it 'should get the source of multi-lined Proc definition' do
    say_hello = Proc.new do
      hello = Hello.new
      hello.say
    end

    expected_expression_src = <<-CODE
hello = Hello.new
hello.say
    CODE

    expect(ProcSourceCode.new(say_hello).to_s).to eq(expected_expression_src.gsub(/\n\z/, ''))
  end

  it 'should get the source of single Proc definition which uses "{ }", in a specific line' do
    say_hello_2 = Proc.new { hello = Hello.new; hello.say }

    expected_expression_src = <<-CODE
hello = Hello.new
hello.say
    CODE

    expect(ProcSourceCode.new(say_hello_2).to_s).to eq(expected_expression_src.gsub(/\n\z/, ''))
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

    expect(ProcSourceCode.new(say_hello_3).to_s).to eq(expected_expression_src.gsub(/\n\z/, ''))
  end

end