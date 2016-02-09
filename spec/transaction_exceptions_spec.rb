require 'rspec'

describe 'Transactions and Exceptions' do
  before do
    @value = 1
  end

  it 'An atomic block that raises an exception should not commit changes' do
    expect {
      Proc.new {
        @value = 2
        raise 'Explosion!'
      }.atomic
    }.to raise_error('Explosion!')

    expect(@value).to eq(1)
  end

  it 'An atomic block that raises an exception should modify a local variable nonetheless' do
    local_var = 1

    expect {
      Proc.new {
        # noinspection RubyUnusedLocalVariable
        local_var = 2
        raise 'Explosion!'
      }.atomic
    }.to raise_error('Explosion!')

    expect(local_var).to eq(2)
  end

  it 'An atomic block that rescues an exception inside, should commit changes correctly' do
    Proc.new {
      begin
        @value = 2
        raise 'Explosion!'
      rescue
        # exception rescued inside atomic block
      end
    }.atomic

    expect(@value).to eq(2)
  end
end