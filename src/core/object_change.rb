require_relative '../ruby_core_ext/object'

class ObjectChange
  def initialize(object)
    # puts "DEBUG: New ObjectChange for #{object.class}->#{object}"
    @original = object
    @working = object.shallow_copy
    @previous = object.shallow_copy
  end

  def working
    @working
  end

  def original
    @original
  end

  def apply
    @original.copy_object_from(@working)
  end

  def has_conflict?
    not @original.has_same_object_state?(@previous)
  end

  def has_changed?
    not @working.has_same_object_state?(@previous)
  end
end
