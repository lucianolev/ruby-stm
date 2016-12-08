require_relative '../ruby_core_ext/object'

class ObjectChange
  def initialize(object)
    @original = object
    @working = object.clone # shallow copy
    @previous = @working.clone # shallow copy
  end

  def working
    @working
  end

  def original
    @original
  end

  def apply
    @original.copy_internal_state(@working)
  end

  def has_conflict?
    not @original.has_same_internal_state?(@previous)
  end

  def has_changed?
    not @working.has_same_internal_state?(@previous)
  end
end
