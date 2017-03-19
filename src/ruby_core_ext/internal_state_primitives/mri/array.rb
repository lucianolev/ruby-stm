class Array
  # As this class is a primitive object implemented in C, it has no instance variables, so we'll use
  # public existant messages to check for internal state equality and copying state

  def has_same_object_state?(an_obj)
    self == an_obj
  end

  private

  def copy_object_state(an_object)
    self.replace(an_object)
  end
end