module Rubinius
  class Tuple
    private

    def start_new_copy
      Rubinius::Type.object_class(self).new(self.size)
    end
  end
end