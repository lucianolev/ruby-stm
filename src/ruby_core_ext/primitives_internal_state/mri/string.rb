class String
  def has_same_internal_state?(an_obj)
    self.eql?(an_obj)
  end

  def copy_internal_state(an_object)
    self.replace(an_object)
  end
end