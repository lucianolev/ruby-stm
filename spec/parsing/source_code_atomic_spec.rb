require 'rspec'

describe SourceCodeAtomic do
  before do
    @source_code_atomic = SourceCodeAtomic.new
  end

  it 'should transform the source of a Proc correctly' do
    proc_def_src = <<-CODE
a_proc = Proc.new {
  myobj = MyObj.new
  local_var = 5
  @instance_var = 8
  another_local = @instance_var
  myobj.method_call
}
CODE
    expected_code = <<-CODE
myobj = MyObj.__atomic__new
local_var = 5
self.atomic_instance_variable_set(:@instance_var, 8)
another_local = self.atomic_instance_variable_get(:@instance_var)
myobj.__atomic__method_call
CODE
    expect(@source_code_atomic.atomic_source_of_proc(proc_def_src)).to eq(expected_code.gsub(/\n\z/, ''))
  end

  xit 'the atomic transformation of a Proc should be able to distinguish a message sent without a receiver from an access
to an outer scope variable' do
    proc_def_src = <<-CODE
a_proc = Proc.new {
  a_method_call_without_explicit_receiver
  local = an_outer_scope_variable
}
    CODE
    expected_code = <<-CODE
__atomic__a_method_call_without_explicit_receiver
local = an_outer_scope_variable
CODE
    expect(@source_code_atomic.atomic_source_of_proc(proc_def_src)).to eq(expected_code.gsub(/\n\z/, ''))
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
  self.atomic_instance_variable_set(:@instance_var, 8)
  another_local = self.atomic_instance_variable_get(:@instance_var)
  myobj.__atomic__method_call
end
CODE
    expect(@source_code_atomic.method_def_to_atomic(method_def_src)).to eq(expected_code.gsub(/\n\z/, ''))
  end
end