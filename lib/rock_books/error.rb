# This error class is intended to differentiate errors from this library from other errors
# when this code is included in external code.
# In addition, more specific error classes in this library can subclass this one.

module RockBooks

class Error < RuntimeError
end

end
