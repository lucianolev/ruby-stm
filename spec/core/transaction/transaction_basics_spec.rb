require 'rspec'
require_relative '../../../ruby_core_ext/proc'

describe 'Transaction basics' do
  before do
    class MyObject
      @class_inst_var = nil

      def initialize
        @instance_var = nil
      end

      def a_message
        'a response'
      end

      def instance_var
        @instance_var
      end

      def instance_var=(value)
        @instance_var = value
      end

      def self.class_inst_var
        @class_inst_var
      end

      def self.class_inst_var=(value)
        @class_inst_var = value
      end
    end
    @my_object = MyObject.new

    @test_instance_var = nil
    @array = [1, 2, 3]
  end

  it 'should return self correctly' do
    proc = Proc.new { self }
    expect(proc.atomic).to eq(self)
  end

  it 'should read an instance var through method correctly' do
    @my_object.instance_var=(1)
    proc = Proc.new { @my_object.instance_var }
    expect(proc.atomic).to eq(1)
  end

  it 'should write an instance var through a method correctly' do
    proc = Proc.new { @my_object.instance_var=(1) }
    proc.atomic
    expect(@my_object.instance_var).to eq(1)
  end

  it 'should read a class instance var through a class method correctly' do
    MyObject.class_inst_var=(1)
    proc = Proc.new { MyObject.class_inst_var }
    expect(proc.atomic).to eq(1)
  end

  it 'should write a class instance var through a class method correctly' do
    proc = Proc.new { MyObject.class_inst_var=(1) }
    proc.atomic
    expect(MyObject.class_inst_var).to eq(1)
  end

  it 'should read an instance variable correctly' do
    @test_instance_var = 1
    proc = Proc.new { @test_instance_var }
    expect(proc.atomic).to eq(1)
  end

  it 'should write an instance variable correctly' do
    proc = Proc.new { @test_instance_var=(1) }
    proc.atomic
    expect(@test_instance_var).to eq(1)
  end

  it 'should read a local variable correctly' do
    a_local_var = 1
    proc = Proc.new { a_local_var }
    expect(proc.atomic).to eq(1)
  end

  it 'should write a local variable correctly' do
    a_local_var = nil
    proc = Proc.new { a_local_var = 1 }
    proc.atomic
    expect(a_local_var).to eq(1)
  end

  it 'should write a local variable correctly' do
    a_local_var = nil
    proc = Proc.new { a_local_var = 1 }
    proc.atomic
    expect(a_local_var).to eq(1)
  end

  it 'should send a message without arguments correctly' do
    proc = Proc.new { 'abc'.reverse }
    expect(proc.atomic).to eq('cba')
  end

  it 'should send a message with argument correctly' do
    proc = Proc.new { 'abc'.concat('def') }
    expect(proc.atomic).to eq('abcdef')
  end

  it 'should send a message to a custom class object correctly' do
    proc = Proc.new { @my_object.a_message }
    expect(proc.atomic).to eq('a response')
  end

  it 'should send an operator-like message correctly' do
    proc = Proc.new { 1 + 2 }
    expect(proc.atomic).to eq(3)
  end

  it 'should read from array using [] operator correctly' do
    proc = Proc.new { @array[0] }
    expect(proc.atomic).to eq(1)
  end

  it 'should write to array using [] operator correctly' do
    proc = Proc.new { @array[0] = 4 }
    proc.atomic
    expect(@array[0]).to eq(4)
  end

  it 'should handle logical operators correctly' do
    proc = Proc.new { true && true }
    expect(proc.atomic).to eq(true)

    proc = Proc.new { true && false }
    expect(proc.atomic).to eq(false)

    proc = Proc.new { true || false }
    expect(proc.atomic).to eq(true)

    proc = Proc.new { 1 == 1 }
    expect(proc.atomic).to eq(true)
  end

  it 'should handle array definition correctly' do
    proc = Proc.new { [1, [2, 3], [4, 5]] }
    expect(proc.atomic).to eq([1, [2, 3], [4, 5]])
  end

  it 'should handle an if-clause correctly' do
    proc = Proc.new {
      # noinspection RubyResolve
      if a_var == 1
        'is 1'
      else
        'is 2'
      end
    }

    a_var = 1
    expect(proc.atomic).to eq('is 1')
    a_var = 2
    expect(proc.atomic).to eq('is 2')
  end

  it 'should handle an while loop correctly' do
    proc = Proc.new {
      i = 0
      while i < 10
        i = i + 1
      end
      i
    }

    expect(proc.atomic).to eq(10)
  end

end