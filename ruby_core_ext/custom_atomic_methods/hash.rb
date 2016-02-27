require_relative '../object'

class Hash
  define_method(atomic_name_of(:set_index)) do |index, obj|
    working_copy.[]=(index, obj)
  end

  define_method(atomic_name_of(:at)) do |index|
    working_copy.[](index)
  end
end