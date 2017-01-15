module Rubinius
  class ByteArray
    private

    def start_new_copy
      Rubinius::Type.object_class(self).allocate_sized(self.size)
    end
  end
end