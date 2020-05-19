#!/usr/bin/env ruby
require './build/graphics'

surface1, surface2 = Graphics::Surface.new, Graphics::Surface.new
Graphics.surface surface1, 640, 480
Graphics.surface surface2, 320, 240

Graphics.fill surface1, :RED
Graphics.fill surface2, :BLUE

window1, window2 = Graphics::Window.new, Graphics::Window.new
Graphics.window window1, "WINDOW 1", 640, 480, :NONE
Graphics.window window2, "WINDOW 2", 320, 240, :RESIZABLE

keyboard_callback = FFI::Function.new(:void, [:pointer, :int, :int, :int], :blocking => true) do |p, key, mod, down|
  puts "KEY EVENT:\nDOWN: #{!down.zero?}\nKEY:  #{Graphics::KeySym[key]}\nMOD:  #{mod.zero? ? 'NONE' : Graphics::KeyMod[mod]}"
end

Graphics.keyboard_callback window1, keyboard_callback
Graphics.keyboard_callback window2, keyboard_callback

while Graphics.closed(window1) != 1
  Graphics.events
  Graphics.flush window1, surface1
  Graphics.flush window2, surface2
end

Graphics.window_destroy window1
Graphics.window_destroy window2
Graphics.surface_destroy surface1
Graphics.surface_destroy surface2