class UnboundMethod

  # PATCH: Rubinius seems to return relative paths for it's core method source location instead of
  # absolute paths like MRI. We patch source_location to return full path in that case
  # See https://github.com/rubinius/rubinius/issues/3729
  # Remove patch when fixed.

  alias_method :orig_source_location, :source_location

  def source_location
    unless orig_source_location.nil?
      file, linenum = orig_source_location
      unless Pathname.new(file).absolute?
        file = File.absolute_path(file, RbConfig::CONFIG['prefix'])
      end
      return file, linenum
    end
  end

  # WORKAROUND: For methods related to attr_* definitions, unlike MRI, source_location in Rubinius returns nil.
  # As a workaround, we implement a special UnboundMethodSourceCode#get_source_code_expression to
  # handle this case, which relies in the methods defined below.
  # See https://github.com/rubinius/rubinius/issues/3727
  # Remove when issue is fixed.

  def is_attr_method?
    self.executable.kind_of? Rubinius::AccessVariable
  end

  def is_attr_writer?
    is_attr_method? && self.executable.arity == 1
  end

  def is_attr_reader?
    is_attr_method? && self.executable.arity == 0
  end
end