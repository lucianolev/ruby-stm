require 'rspec'
require_relative '../../../src/stm'

describe 'Transactions on control expressions' do
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

  it 'should handle an while loop correctly' do
    proc = Proc.new {
      c = 0
      # noinspection RubyForLoopInspection
      for i in 0..10
        c = c + i
      end
      c
    }

    expect(proc.atomic).to eq(55)
  end

end