class Object
  def has_same_internal_state?(an_obj)
    self.all_instance_variables.all? do |ivar_name|
      ivar_self = self.instance_variable_get(ivar_name)
      ivar_an_obj = an_obj.instance_variable_get(ivar_name)
      ivar_self.equal?(ivar_an_obj)
    end
  end

  def copy_internal_state(an_object)
    an_object.all_instance_variables.each do |inst_var_name|
      self.instance_variable_set(inst_var_name,
                                 an_object.instance_variable_get(inst_var_name))
    end
  end

  # Real shallow copy. Not included in MRI. Will probably depend on VM primitives.
  def shallow_copy
    raise 'Must override for specific Ruby implementation'
  end

  protected

  # Some implementations may hide instance variables from primitive values. Override if needed.
  def all_instance_variables
    instance_variables
  end
end

if RUBY_ENGINE == 'rbx'
  Dir[File.join(__dir__, 'rbx', '*.rb')].each { |file| require_relative file }
end
if RUBY_ENGINE == 'ruby'
  Dir[File.join(__dir__, 'mri', '*.rb')].each { |file| require_relative file }
end