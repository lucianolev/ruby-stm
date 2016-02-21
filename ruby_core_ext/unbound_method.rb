require_relative '../parsing/source_code_parser'
require 'pathname'

class UnboundMethod
  def is_native?
    source_location.nil?
  end

  def is_a_kernel_alpha_method?
    if RUBY_ENGINE == 'rbx'
      unless source_location.nil?
        return source_location[0] == File.join(RbConfig::CONFIG['prefix'], 'kernel/alpha.rb')
      end
    end
    false
  end

  def definition
    if is_native?
      raise 'Cannot get source code of a native method.'
    end
    SourceCodeParser.new.get_method_definition(self)
  end

  if RUBY_ENGINE == 'rbx'
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

end