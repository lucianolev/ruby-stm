require 'rspec'
require_relative '../../../src/stm'

describe 'Transactions on collections' do
  before do
    @array = [1, 2, 3]
    @hash = {a: 1, b: 2, c: 3}
  end

  it 'should handle array definition correctly' do
    proc = Proc.new { [1, [2, 3], [4, 5]] }
    expect(proc.atomic).to eq([1, [2, 3], [4, 5]])
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

  it 'should handle hash definition correctly' do
    proc_a = Proc.new { {a: 1, b: 2} }
    proc_b = Proc.new { {:a => 1, :b => 2} }
    proc_c = Proc.new { {'a' => 1, 'b' => 2} }
    expect(proc_a.atomic).to eq({a: 1, b: 2})
    expect(proc_b.atomic).to eq({a: 1, b: 2})
    expect(proc_c.atomic).to eq({'a' => 1, 'b' => 2})
  end

  it 'should read from hash using [] operator correctly' do
    proc = Proc.new { @hash[:a] }
    expect(proc.atomic).to eq(1)
  end

  it 'should write to hash using [] operator correctly' do
    proc = Proc.new { @hash[:b] = 4 }
    proc.atomic
    expect(@hash[:b]).to eq(4)
  end
end