require_relative 'ruby_core_ext/proc'

# test 1

class Hello
  def say
    @internal_var = 'hello'
    local_var = @internal_var
    puts local_var
  end
end

say_hello = Proc.new do
  hello = Hello.new
  hello.say
end

puts say_hello.atomic

# test 2

class MyObject
  def initialize
    @internal_var = 1
  end

  def set_var(elem)
    @internal_var = elem
  end
end

list_oops = Proc.new do
  my_list = MyObject.new
  my_list.set_var(2)
  my_list
end

puts list_oops.atomic.inspect