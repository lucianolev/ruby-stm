class UnboundMethod

  # Rubinius seems to return relative paths for it's core method source location instead of absolute paths like MRI.
  # We patch source_location to return full path in that case

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
end