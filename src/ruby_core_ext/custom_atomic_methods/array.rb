require_relative '../symbol'
require_relative '../object'

class Array
  define_method(:set_index.to_atomic_method_name) do |index, obj|
    working_copy.[]=(index, obj)
  end

  define_method(:at.to_atomic_method_name) do |index|
    working_copy.[](index)
  end
end