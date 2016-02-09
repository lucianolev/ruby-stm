require 'rspec'
require_relative '../../parsing/source_code_atomic_transformer'

describe SourceCodeAtomicTransformer do
  before do
    @source_code_atomic = SourceCodeAtomicTransformer.new
  end

  it 'should transform multi-line source code correctly' do
    proc_def_src = <<-CODE
myobj = MyObj.new
local_var = 5
@instance_var = 8
another_local = @instance_var
myobj.method_call
CODE
    expected_code = <<-CODE
myobj = MyObj.__atomic__new
local_var = 5
self.__atomic__instance_variable_set(:@instance_var, 8)
another_local = self.__atomic__instance_variable_get(:@instance_var)
myobj.__atomic__method_call
CODE
    expect(@source_code_atomic.transform_source_code(proc_def_src)).to eq(expected_code.gsub(/\n\z/, ''))
  end

  it 'should transform single-line source code correctly' do
    proc_def_src = <<-CODE
local_var = 5
CODE
    expected_code = <<-CODE
local_var = 5
CODE
    expect(@source_code_atomic.transform_source_code(proc_def_src)).to eq(expected_code.gsub(/\n\z/, ''))
  end

  xit 'the atomic transformation of a Proc should be able to distinguish a message sent without a receiver from an access
to an outer scope variable' do
    proc_def_src = <<-CODE
a_method_call_without_explicit_receiver
local = an_outer_scope_variable
    CODE
    expected_code = <<-CODE
__atomic__a_method_call_without_explicit_receiver
local = an_outer_scope_variable
CODE
    expect(@source_code_atomic.transform_source_code(proc_def_src)).to eq(expected_code.gsub(/\n\z/, ''))
  end

  it 'should generate the atomic version of a method definition correctly' do
    method_def_src = <<-CODE
def a_method
  myobj = MyObj.new
  local_var = 5
  @instance_var = 8
  another_local = @instance_var
  myobj.method_call
end
CODE
    expected_code = <<-CODE
def __atomic__a_method
  myobj = MyObj.__atomic__new
  local_var = 5
  self.__atomic__instance_variable_set(:@instance_var, 8)
  another_local = self.__atomic__instance_variable_get(:@instance_var)
  myobj.__atomic__method_call
end
CODE
    expect(@source_code_atomic.transform_method_definition(method_def_src)).to eq(expected_code.gsub(/\n\z/, ''))
  end

  it 'should generate the atomic version of a CLASS method definition correctly' do
    method_def_src = <<-CODE
def self.a_method
  a_var = 1
end
CODE
    expected_code = <<-CODE
def self.__atomic__a_method
  a_var = 1
end
CODE
    expect(@source_code_atomic.transform_method_definition(method_def_src)).to eq(expected_code.gsub(/\n\z/, ''))
  end
end