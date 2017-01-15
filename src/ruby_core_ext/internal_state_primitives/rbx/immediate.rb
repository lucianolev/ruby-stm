module ImmediateValue
  private

  def start_new_copy
    raise TypeError, "can't shallow copy #{self.class.name}"
  end
end