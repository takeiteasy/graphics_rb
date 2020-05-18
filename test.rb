require 'ffi'
require './build/graphics'

$WINDOW, $SCREEN, $INPUT, $RUNNING = nil, nil, nil, false

class Input
  
end

class Surface
  attr_reader :width, :height
  
  def initialize w, h
    @width = w
    @height = h
    @surface = Graphics::Surface.new
    Graphics.surface @surface, @width, @height
    ObjectSpace.define_finalizer(self, self.class.method(:finalize))
  end
  
  def fill c
    Graphics.fill @surface, c
  end
  
  def blit x, y, to=nil
    Graphics.paste (to ? to : $SCREEN), @surface, x, y
  end
  
  def native
    @surface
  end
  
  def self.finalize x
    proc { Graphics.surface_destroy @surface }
  end
end

class Sprite < Surface
  attr_accessor :x, :y
  
  def initialize w, h, x=0, y=0
    @x = x
    @y = y
    super w, h
  end
  
  def blit to=nil
    super @x, @y, to
  end
end

def run w, h, title="Ruby BGI", sw=nil, sh=nil
  graphics_error_callback, = FFI::Function.new(:void, [:int, :pointer, :pointer, :pointer, :int], :blocking => true) do |err, msg, file, func, line|
    raise "ERROR! in #{file} @ line #{line} in #{file} -- #{msg}"
  end
  Graphics.graphics_error_callback graphics_error_callback
  
  raise "Window already created!" if $WINDOW
  sw = w unless sw
  sh = h unless sh
  puts sw, sh
  $WINDOW = Graphics::Window.new
  raise "Failed to create window!" unless Graphics.window $WINDOW, title, w, h, :NONE
  $SCREEN = Graphics::Surface.new
  Graphics.surface $SCREEN, sw, sh
  $RUNNING = true
  
  keyboard_callback = FFI::Function.new(:void, [:pointer, :int, :int, :int], :blocking => true) do |p, key, mod, down|
  end
  mouse_button_callback = FFI::Function.new(:void, [:pointer, :int, :int, :int], :blocking => true) do |p, btn, mod, down|
  end
  mouse_move_callback = FFI::Function.new(:void, [:pointer, :int, :int, :int, :int], :blocking => true) do |p, x, y, dx, dy|
  end
  scroll_callback = FFI::Function.new(:void, [:pointer, :int, :float, :float], :blocking => true) do |p, mod, dx, dy|
  end
  focus_callback, = FFI::Function.new(:void, [:pointer, :int], :blocking => true) do |p, focused|
    # TODO: Pause loop while unfocused?
  end
  resize_callback = FFI::Function.new(:void, [:pointer, :int, :int], :blocking => true) do |p, w, h|
    # TODO: Allow resizing?
  end
  closed_callback = FFI::Function.new(:void, [:pointer], :blocking => true) do |p|
    $RUNNING = false
  end
  Graphics.window_callbacks keyboard_callback,
                            mouse_button_callback,
                            mouse_move_callback,
                            scroll_callback,
                            focus_callback,
                            resize_callback,
                            closed_callback,
                            $WINDOW
  
  return unless block_given?
  while Graphics.closed($WINDOW) != 1 and $RUNNING
    Graphics.events
    yield
    Graphics.flush $WINDOW, $SCREEN
  end
end

def cls c=:BLACK
  Graphics.fill $SCREEN, c if $SCREEN
end

test = Surface.new 100, 100
test.fill :RED

run 640, 480 do
  cls
  test.blit 10, 10
end
