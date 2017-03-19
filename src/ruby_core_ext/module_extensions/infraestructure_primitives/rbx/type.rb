module Rubinius
  module Type
    class << self
      infrastructure_primitives :object_kind_of?, :object_equal,
                                :singleton_class_object, :object_class,
                                :infect, :module_name
    end
  end
end