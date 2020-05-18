module Graphics
  extend FFI::Library
  ffi_lib "build/graphics.dylib"
  
$ENUMS
  
$CALLBACKS
  
$FUNCTIONS
end

def RGBA r, g, b, a
  a << 24 | r << 16 | g << 8 | b
end

def RGB r, g, b
  RGBA r, g, b, 255
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

$STRUCTS
