require_relative 'ruby_core_ext/proc'

class Hello
  def say
    @internal_list = "hello"
    local_var = @internal_list
    puts local_var
  end
end


say_hello = Proc.new do
  hello = Hello.new
  hello.say
end

puts say_hello.atomic

class MyList
  def initialize
    @internal_list = Array.new
  end

  def add(elem)
    @internal_list.push(elem)
  end
end

list_oops = Proc.new do
  my_list = MyList.new
  my_list.add(1)
  my_list.inspect
end

#puts list_oops.atomic