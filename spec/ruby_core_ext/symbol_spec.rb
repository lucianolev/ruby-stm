require 'rspec'
require_relative '../../ruby_core_ext/symbol'

describe Symbol do

  it 'should correclty identify an atomic method name' do
    expect(:a_normal_method_name.is_an_atomic_method_name?).to eq(false)
    expect(:+.is_an_atomic_method_name?).to eq(false)
    expect(:__atomic__method_name.is_an_atomic_method_name?).to eq(true)
  end

  it 'should return the non-atomic name of an atomic method name correclty' do
    expect(:__atomic__method_name.to_nonatomic_method_name).to eq(:method_name)
    expect(:method_name.to_nonatomic_method_name).to eq(:method_name)
    expect(:__atomic__add.to_nonatomic_method_name).to eq(:+)
  end

  it 'should return the atomic name of a non-atomic method name correclty' do
    expect(:method_name.to_atomic_method_name).to eq(:__atomic__method_name)
    expect(:+.to_atomic_method_name).to eq(:__atomic__add)
  end

end