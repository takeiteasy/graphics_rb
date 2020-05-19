require 'ffi'
require './build/graphics'

$WINDOW, $SCREEN, $INPUT, $RUNNING = nil, nil, nil, false

class Integer
  def max n
    self > n ? self : n
  end
  
  def min n
    self < n ? self : n
  end
  
  def clamp a, b
    self.min(a).max(b)
  end
  
  def between? a, b
    self > a and self < b
  end
  
  def between_or? a, b
    self >= a and self <= b
  end
  
  def lerp to, n
    (to * n) + (self * (1 - n))
  end
  
  def smoothstep to, n
    self.lerp to, (n ** 2 * (3 - 2 * n))
  end
  
  def smootherstep to, n
    self.lerp to, (n ** 3 * (n * (n * 6 - 15) + 10))
  end
  
  def radians
    self * (Math::PI / 180.0)
  end
  
  def degrees
    self * (180.0 / M_PI)
  end
  
  def to_bool
    !self.zero?
  end
end

class Vec2
  attr_accessor :x, :y
  
  def initialize x=0, y=0
    @x = x
    @y = y
  end
  
  def + v
    if v.class == Fixnum
      Vec2.new @x + v, @y + v
    else
      Vec2.new @x + v.x, @y + v.y
    end
  end

  def - v
    if v.class == Fixnum
      Vec2.new @x - v, @y - v
    else
      Vec2.new @x - v.x, @y - v.y
    end
  end

  def / v
    if v.class == Fixnum
      Vec2.new @x / v, @y / v
    else
      Vec2.new @x / v.x, @y / v.y
    end
  end

  def * v
    if v.class == Fixnum
      Vec2.new @x * v, @y * v
    else
      Vec2.new @x * v.x, @y * v.y
    end
  end

  def neg
    Vec2.new -@x, -@y
  end

  def pow n
    Vec2.new @x ** n, @y ** n
  end

  def abs
    Vec2.new @x.abs, @y.abs
  end

  def eql? v
    @x == v.x and @y == v.y
  end
  
  alias_method :equal?, :eql?
  alias_method :==,     :eql?
  alias_method :===,    :eql?

  def floor
    Vec2.new @x.floor, @y.floor
  end

  def ceil
    Vec2.new @x.ceil, @y.ceil
  end

  def dot v
    @x * v.x + @y * v.y
  end

  def length_sqrd
    @x ** 2 + @y ** 2
  end

  def length
    Math.sqrt self.length_sqrd
  end

  def dist_sqrd v
    (@x - v.x) ** 2 + (@y - v.y) ** 2
  end

  def dist v
    Math.sqrt(self.dist_sqrd v)
  end

  def normalise
    self / self.length
  end

  def reflect v
    self - (v * (self.dot(v) * 2))
  end
  
  def min n
    Vec2.new @x.min(n), @y.min(n)
  end
  
  def max n
    Vec2.new @x.max(n), @y.max(n)
  end
  
  def clamp a, b
    Vec2.new @x.clamp(a, b), @y.clamp(a, b)
  end
  
  def lerp v, n
    Vec2.new @x.lerp(v.x, n), @y.lerp(v.y, n)
  end
  
  def smoothstep v, n
    Vec2.new @x.smoothstep(v.x, n), @y.smoothstep(v.y, n)
  end
  
  def smootherstep v, n
    Vec2.new @x.smootherstep(v.x, n), @y.smootherstep(v.y, n)
  end

  def to_s
    "[#{@x}, #{@y}]"
  end
end

class Input
  attr_accessor :keys, :keys_down_tick, :keys_up_tick
  attr_accessor :btns, :btns_down_tick, :btns_up_tick
  attr_accessor :modifier, :cursor_pos, :cursor_last_pos, :scroll
  
  def initialize
    @keys = []
    @keys_down_tick = []
    @keys_up_tick = []
    @btns = []
    @btns_down_tick = []
    @btns_up_tick = []
    @modifier = 0
    @cursor_pos = Vec2.new
    @cursor_last_pos = Vec2.new
    @scroll = Vec2.new
  end
end

def is_key_down? key
  $INPUT.keys[Graphics::KeySym[key]]
end

def is_key_up? key
  !!$INPUT.keys[Graphics::KeySym[key]]
end

def all_keys_down? *keys
  keys.each do |k|
    false unless key_down? k
  end
  true
end

def any_keys_down? *keys
  keys.each do |k|
    true if key_down? k
  end
  false
end

def to_screen? s
  case s
  when NilClass
    $SCREEN
  when Surface
    s.native
  when Graphics::Surface
    s
  else
    raise "[ERROR] Invalid Surface!"
  end
end

class Surface
  attr_reader :width, :height
  
  def initialize w, h=nil
    @surface = Graphics::Surface.new
    case w
    when Fixnum
      @width  = w
      @height = h ? w : h
      Graphics.surface @surface, @width, @height
    when String
      Graphics.bmp @surface, w
      @width  = @surface[:w]
      @height = @surface[:h]
    else raise "[ERROR] Invalid Surface initialize type"
    end
    ObjectSpace.define_finalizer(self, self.class.method(:finalize))
  end
  
  def fill c
    Graphics.fill @surface, c
  end
  
  def blit x, y, to=nil
    Graphics.paste to_screen?(to), @surface, x, y
  end
  
  def load path
    Graphics.bmp @surface, path
  end
  
  def save path
    Graphics.save_bmp @surface, path
  end
  
  def passthru
    raise "[ERROR] Passthru requires a block!" unless block_given?
    for x in 0..@width
      for y in 0..@height
        Graphics.pset @surface, x, y, yield(x, y, Graphics.pget(@surface, x, y))
      end
    end
  end
  
  def native
    @surface
  end
  
  def self.finalize x
    proc { Graphics.surface_destroy @surface }
  end
end

class Sprite < Surface
  attr_accessor :pos
  
  def initialize w, h, x=0, y=0
    @pos = Vec2.new x, y
    super w, h
  end
  
  def blit to=nil
    super @pos.x, @pos.y, to
  end
end

def cls c=:BLACK
  Graphics.fill $SCREEN, c if $SCREEN
end

def line x1, y1, x2, y2, col, to=nil
  Graphics.line to_screen?(to), x1, y1, x2, y2, col
end

def circle xc, yc, r, col, fill=false, to=nil
  Graphics.circle to_screen?(to), xc, yc, r, col, fill
end

def rect x, y, w, h, col, fill=false, to=nil
  Graphics.rect to_screen?(to), x, y, w, h, col, fill
end

def tri x1, y1, x2, y2, x3, y3, col, fill=false, to=nil
  Graphics.tri to_screen?(to), x1, y1, x2, y2, x3, y3, col, fill
end

def pset x, y, col, to=nil
  Graphics.pset to_screen?(to), x, y, col
end

def pget x, y, to=nil
  Graphics.pget to_screen?(to), x, y
end

def writeln x, y, fg, bg, str, to=nil
  Graphics.writeln to_screen?(to), x, y, fg, bg, str
end

def run w, h, title="Ruby BGI", sw=nil, sh=nil
  graphics_error_callback, = FFI::Function.new(:void, [:int, :pointer, :pointer, :pointer, :int], :blocking => true) do |err, msg, file, func, line|
    raise "ERROR! in #{file} @ line #{line} in #{file} -- #{msg}"
  end
  Graphics.graphics_error_callback graphics_error_callback
  
  raise "Window already created!" if $WINDOW
  sw = w unless sw
  sh = h unless sh
  $WINDOW = Graphics::Window.new
  raise "Failed to create window!" unless Graphics.window $WINDOW, title, w, h, :NONE
  $SCREEN = Graphics::Surface.new
  Graphics.surface $SCREEN, sw, sh
  $INPUT = Input.new
  $RUNNING = true
  
  keyboard_callback = FFI::Function.new(:void, [:pointer, :int, :int, :int], :blocking => true) do |p, key, mod, down|
    $INPUT.keys[key] = down.to_bool
    $INPUT.modifier = mod
  end
  mouse_button_callback = FFI::Function.new(:void, [:pointer, :int, :int, :int], :blocking => true) do |p, btn, mod, down|
    $INPUT.btns[btn] = down.to_bool
    $INPUT.modifier = mod
  end
  mouse_move_callback = FFI::Function.new(:void, [:pointer, :int, :int, :int, :int], :blocking => true) do |p, x, y, dx, dy|
    $INPUT.cursor_last_pos.x = $INPUT.cursor_pos.x
    $INPUT.cursor_last_pos.y = $INPUT.cursor_pos.y
    $INPUT.cursor_pos.x = x
    $INPUT.cursor_pos.y = y
  end
  scroll_callback = FFI::Function.new(:void, [:pointer, :int, :float, :float], :blocking => true) do |p, mod, dx, dy|
    $INPUT.scroll.x = dx
    $INPUT.scroll.y = dy
    $INPUT.modifier = mod
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
    $INPUT.scroll.x = 0
    $INPUT.scroll.y = 0
    Graphics.flush $WINDOW, $SCREEN
  end
  Graphics.window_destroy $WINDOW if $WINDOW
  Graphics.surface_destroy $SCREEN if $SCREEN
end
