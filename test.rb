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

obj_code = Proc.new do
  my_obj = MyObject.new
  my_obj.set_var(2)
  my_obj
end

puts obj_code.atomic.inspect

# test 3

require_relative 'ruby_core_ext/array'

class MyList
  def initialize
    @internal_var = [1, 2, 3]
  end

  def set_elem(elem)
    local = 5
    @internal_var[1] = 3 + local
    @internal_var[0] = elem
  end
end

list_code = Proc.new do
  my_list = MyList.new
  my_list.set_elem(2)
  my_list
end

puts list_code.atomic.inspect