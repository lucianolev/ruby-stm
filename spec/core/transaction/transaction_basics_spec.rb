require 'rspec'
require_relative '../../../ruby_core_ext/proc'

describe 'Transaction basics' do
  before do
    class MyObject
      @class_inst_var = nil

      def initialize
        @instance_var = nil
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
end