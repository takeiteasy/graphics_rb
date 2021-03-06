require 'ffi'

module Graphics
  extend FFI::Library
  ffi_lib "build/graphics.dylib"
  
$ENUMS
  
$CALLBACKS
  
$FUNCTIONS

$STRUCTS
end

class Integer
  INT_MAX = 4294967295
  
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

def RGBA r, g, b, a=255
  a << 24 || r << 16 | g << 8 | b
end

class Pixel
  attr_accessor :r, :g, :b, :a
  
  def initialize r=0, g=0, b=0, a=0
    @r = r
    @g = g
    @b = b
    @a = a
  end
  
  def to_i
    RGBA @r, @g, @b, @a
  end
end
