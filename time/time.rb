require 'ffi'

module SysTime
  extend FFI::Library
  ffi_lib "build/time.dylib"
  
  attach_function :ticks, [], :long
end