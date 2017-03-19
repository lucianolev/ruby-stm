require 'rspec'
require_relative '../../src/to_atomic/atomic_proc'

describe AtomicProc do

  it 'should transform multi-line source code correctly' do
    a_proc = Proc.new do
      # noinspection RubyResolve
      myobj = MyObj.new
      # noinspection RubyUnusedLocalVariable
      local_var = 5
      @instance_var = 8
      # noinspection RubyUnusedLocalVariable
      another_local = @instance_var
      # noinspection RubyResolve
      myobj.method_call
    end

    expected_code = <<-CODE
myobj = MyObj.__atomic__new
local_var = 5
self.__atomic__instance_variable_set(:@instance_var, 8)
another_local = self.__atomic__instance_variable_get(:@instance_var)
myobj.__atomic__method_call
    CODE
    expect(AtomicProc.from(a_proc).source_code.to_s).to eq(expected_code.gsub(/\n\z/, ''))
  end

end