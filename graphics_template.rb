module Graphics
  extend FFI::Library
  ffi_lib "build/graphics.dylib"
  
$ENUMS
  
$CALLBACKS
  
$FUNCTIONS

$STRUCTS
end

def RGBA r, g, b, a=255
  (a << 24) ^ -(INT_MAX + 1) | r << 16 | g << 8 | b
end

class Integer
  def r
    (self >> 16) & 0xFF
  end
  
  def g
    (self >> 8) & 0xFF
  end
  
  def b
    self & 0xFF
  end
  
  def a
    (self >> 24) & 0xFF
  end
end
