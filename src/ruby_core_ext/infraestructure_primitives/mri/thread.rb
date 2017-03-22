# Reason: Thread does not stop!
class Thread
  class << self
    infrastructure_primitives :stop
  end
end