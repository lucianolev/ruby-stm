module Rubinius
  class Tuple
    def has_same_object_state?(other_tuple)
      other_tuple.length.times.all? do |i|
        self[i].equal?(other_tuple[i])
      end
    end

    private

    def start_new_copy
      self.class.new(self.size)
    end
  end
end