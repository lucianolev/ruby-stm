module Rubinius
  class ByteArray
    def has_same_object_state?(other_bytearray)
      other_bytearray.size.times.all? do |i|
        get_byte(i).equal?(other_bytearray.get_byte(i))
      end
    end

    private

    def start_new_copy
      self.class.allocate_sized(self.size)
    end
  end
end