require_relative 'class_extensions/all'

class Class < Module
  def subclasses_implementing_message(message)
    self.all_subclasses.select do |klass|
      klass.instance_methods(false).include?(message)
    end
  end

  def all_subclasses
    metaclass = self.singleton_class
    subclasses_including_self = ObjectSpace.each_object(metaclass)
    subclasses_including_self.reject { |klass| klass == self }
  end
end