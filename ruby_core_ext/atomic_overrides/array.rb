require_relative '../../ruby_core_ext/object'

class Array
  def __atomic__set_index(index, obj)
    working_copy.[]=(index, obj)
  end
  def __atomic__at(index)
    working_copy.[](index)
  end
end