require 'ffi'
require './build/graphics'

Callback = FFI::Function.new(:void, [:pointer, :int, :int, :int],
                             :blocking => true) do |a, b, c, d|
  puts a, b, c, d
end

window = Window.new
puts Graphics.window(window, "test", 640, 480, 0)

Graphics.keyboard_callback window, Callback

surface = Surface.new
Graphics.surface surface, 640, 480
Graphics.fill surface, :BLACK

while true
  Graphics.events
  Graphics.flush window, surface
end
