require 'rspec'

describe 'Transaction message sending' do
  before do
    class MyObject
      def a_message
        'a response'
      end

      def a_message_with_def_arg(a, b = 1)
        a + b
      end

      def a_message_with_key_arg(a, b: 1)
        a + b
      end

      alias_method :alias_message, :a_message
    end
    @my_object = MyObject.new
  end

  it 'should send a message without arguments correctly' do
    proc = Proc.new { 'abc'.reverse }
    expect(proc.atomic).to eq('cba')
  end

  it 'should send a message without arguments and without an explicit receiver correctly' do
    proc = Proc.new { nil? }
    expect(proc.atomic).to eq(false)
  end

  it 'should send a message with argument correctly' do
    proc = Proc.new { 'abc'.include?('c') }
    expect(proc.atomic).to eq(true)
  end

  it 'should send a message with default positional argument correctly' do
    proc = Proc.new { @my_object.a_message_with_def_arg(1) }
    expect(proc.atomic).to eq(2)
  end

  it 'should send a message with keyword argument correctly' do
    proc = Proc.new { @my_object.a_message_with_key_arg(1, b: 2) }
    expect(proc.atomic).to eq(3)
  end

  it 'should handle a message sent with a block as an argument correctly' do
    proc = Proc.new {
      i = 0
      10.times { i = i + 1 }
      i
    }

    expect(proc.atomic).to eq(10)
  end

  it 'should send a message to a custom class object correctly' do
    proc = Proc.new { @my_object.a_message }
    expect(proc.atomic).to eq('a response')
  end

  it 'should send an operator-like message correctly' do
    proc = Proc.new { 1 + 2 }
    expect(proc.atomic).to eq(3)
  end

  it 'should send a message defined as a singleton method correctly' do
    my_object = MyObject.new

    def my_object.a_singleton_method
      'a response of a singleton method'
    end

    proc = Proc.new { my_object.a_singleton_method }
    expect(proc.atomic).to eq('a response of a singleton method')
  end

  it 'should send a message defined by alias_method correctly' do
    proc = Proc.new { @my_object.alias_message }
    expect(proc.atomic).to eq('a response')
  end

  it 'should handle a block call correctly' do
    outer_var = 1
    inc_1 = proc { |a| a + outer_var + 1 }
    proc = Proc.new { inc_1.call(1) }
    expect(proc.atomic).to eq(3)
  end
end