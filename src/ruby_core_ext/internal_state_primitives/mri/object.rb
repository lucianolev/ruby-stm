class Object

  # 'clone' seems like a good call but it may have additional behaviour implemented in initialize_copy
  # for subclasses, so it's not totally safe to use it.
  # TODO: Research a way to do a realiable shallow copy of a ruby object in MRI.
  def shallow_copy
    clone
  end
end