require 'rspec'

describe SourceCodeReader do
  before do
    @source_code_reader = SourceCodeReader.new
    @file = File.absolute_path('spec/parsing/test_data/source.rb.txt')
  end

  it 'should get the source of multi-line Proc definition in a specific line' do
    expression_src = @source_code_reader.get_src_of_first_expression_in(@file, 16)
    expected_expression_src = <<-CODE
say_hello = Proc.new do
  hello = Hello.new
  hello.say
end
CODE
    expect(expression_src).to eq(expected_expression_src)
  end

  it 'should get the source of single Proc definition which uses "{ }", in a specific line' do
    expression_src = @source_code_reader.get_src_of_first_expression_in(@file, 21)
    expected_expression_src = <<-CODE
say_hello_2 = Proc.new { hello = Hello.new; hello.say }
    CODE
    expect(expression_src).to eq(expected_expression_src)
  end

  it 'should get the source of two-line Proc definition, with a break after "=", in a specific line' do
    expression_src = @source_code_reader.get_src_of_first_expression_in(@file, 23)
    expected_expression_src = <<-CODE
say_hello_3 =
Proc.new do hello = Hello.new; hello.say end
CODE
    expect(expression_src).to eq(expected_expression_src)
  end

  it 'should get the source of a method def inside a class' do
    expression_src = @source_code_reader.get_src_of_first_expression_in(@file, 9)
    expected_expression_src = <<-CODE
  def say
    @internal_var = 'hello'
    local_var = @internal_var
    puts local_var
  end
    CODE
    expect(expression_src).to eq(expected_expression_src)
  end

  it 'should get the source of a method def in the main scope' do
    expression_src = @source_code_reader.get_src_of_first_expression_in(@file, 26)
    expected_expression_src = <<-CODE
def my_func
  a = x + 5
end
    CODE
    expect(expression_src).to eq(expected_expression_src)
  end

  it 'should get the source of a class method def' do
    expression_src = @source_code_reader.get_src_of_first_expression_in(@file, 6)
    expected_expression_src = <<-CODE
  def self.a_class_method
    puts 'hello'
  end
    CODE
    expect(expression_src).to eq(expected_expression_src)
  end
end