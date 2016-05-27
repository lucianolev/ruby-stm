require 'rspec'
require_relative '../../../src/ruby_core_ext/proc'

describe 'Transaction basics' do
  before do
    class MyObject
      @class_inst_var = nil

      attr_accessor :attr_accessor_ivar
      attr_reader :attr_reader_ivar
      attr_writer :attr_writer_ivar

      def initialize
        @instance_var = nil
        @attr_reader_ivar = 1
        @attr_writer_ivar = nil
      end

      def instance_var
        @instance_var
      end

      def attr_writer_ivar
        @attr_writer_ivar
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

  it 'should read an instance variable correctly through attr_accessor' do
    @my_object.attr_accessor_ivar = 1
    proc = Proc.new { @my_object.attr_accessor_ivar }
    expect(proc.atomic).to eq(1)
  end

  it 'should write an instance variable correctly through attr_accessor' do
    proc = Proc.new { @my_object.attr_accessor_ivar = 1 }
    proc.atomic
    expect(@my_object.attr_accessor_ivar).to eq(1)
  end

  it 'should read an instance variable correctly through attr_reader' do
    proc = Proc.new { @my_object.attr_reader_ivar }
    expect(proc.atomic).to eq(1)
  end

  it 'should write an instance variable correctly through attr_writer' do
    proc = Proc.new { @my_object.attr_writer_ivar = 1 }
    proc.atomic
    expect(@my_object.attr_writer_ivar).to eq(1)
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