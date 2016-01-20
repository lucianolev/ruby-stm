require_relative '../ruby_core_ext/object'

class ObjectChange
  attr_reader :working

  def initialize(object)
    @original = object
    @working = object.clone # shallow copy :)
    @previous = @working.clone # shallow copy :)
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
