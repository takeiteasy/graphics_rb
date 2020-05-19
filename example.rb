require './rgi'

class Vec2
  def rotate n
    Vec2.new self.x * Math.cos(n) - self.y * Math.sin(n),
             self.x * Math.sin(n) + self.y * Math.cos(n)
  end
end

$tile_map = {
  :FLOOR => nil,
  :WALL1 => :RED,
  :WALL2 => :BLUE,
  :WALL3 => :GREEN,
  :WALL4 => :YELLOW,
  :WALL5 => :PINK }
      
class Map
  attr_accessor :map
  
  def initialize path
    @map = []
    File.read(path).split("\n").each_with_index do |l|
      map << l.split('').map(&:to_i).map { |i| $tile_map.keys[i] }
    end
  end
  
  def [] idx
    @map[idx]
  end
  
  def at p
    @map[p.x][p.y]
  end
end

class Player
  attr_accessor :map, :pos, :dir, :cam
  
  def initialize map, x=0.0, y=0.0, dx=0.0, dy=0.0, px=0.0, py=0.0
    @map = map
    @pos = Vec2.new x,  y
    @dir = Vec2.new dx, dy
    @cam = Vec2.new px, py
  end
  
  def cast_ray x
    Vec2.new dir.x + cam.x * x, dir.y + cam.y * x
  end
  
  def map_pos
    Vec2.new pos.x.floor, pos.y.floor
  end
  
  def move n
    delta  = @dir * n
    dx, dy = [Vec2.new(@pos.x + delta.x, @pos.y), Vec2.new(@pos.x, @pos.y + delta.y)]
    @pos.x += delta.x if @map.at(dx) == :FLOOR
    @pos.y += delta.y if @map.at(dy) == :FLOOR
  end
  
  def rotate n
    @dir = @dir.rotate n
    @cam = @cam.rotate n
  end
end

WINDOWW = 640
WINDOWH = 480
RENDERW = 640
RENDERH = 480
RESIZE  = false

map = Map.new "map.txt"
player = Player.new map, 22, 12, -1, 0, 0, 0.66
      
run WINDOWW, WINDOWH, "TEST!", RENDERW, RENDERH, RESIZE do |dt, fps|
  cls
  
  for x in 0..RENDERW
    ray = player.cast_ray 2.0 * x / RENDERW - 1.0
    map_pos = player.map_pos
    delta_dist = Vec2.new (1.0 / ray.x).abs, (1.0 / ray.y).abs
    step = Vec2.new ray.x < 0 ? -1 : 1, ray.y < 0 ? -1 : 1
    side_dist = Vec2.new ray.x < 0 ? (player.pos.x - map_pos.x) * delta_dist.x : (map_pos.x + 1.0 - player.pos.x) * delta_dist.x,
                         ray.y < 0 ? (player.pos.y - map_pos.y) * delta_dist.y : (map_pos.y + 1.0 - player.pos.y) * delta_dist.y
    
    tile, side = nil, false
    while true
      if side_dist.x < side_dist.y
        side_dist.x += delta_dist.x
        map_pos.x += step.x
        side = false
      else
        side_dist.y += delta_dist.y
        map_pos.y += step.y
        side = true
      end
      
      tile = map.at map_pos
      break unless tile == :FLOOR
    end
    
    perp_wall_dist = side ? (map_pos.y - player.pos.y + (1 - step.y) / 2) / ray.y :
                            (map_pos.x - player.pos.x + (1 - step.x) / 2) / ray.x
                            
    wall_height = (RENDERH / perp_wall_dist).floor
    wall_size   = Vec2.new (-wall_height / 2.0 + RENDERH / 2.0).round.max(0),
                           ( wall_height / 2.0 + RENDERH / 2.0).round.min(RENDERH - 1)

    line x, wall_size.x, x, wall_size.y, $tile_map[tile]
  end
  
  move_speed, rot_speed = dt * 5.0, dt * 3.0
  player.move move_speed if is_key_down? :KB_KEY_W
  player.move -move_speed if is_key_down? :KB_KEY_S
  player.rotate -rot_speed if is_key_down? :KB_KEY_D
  player.rotate rot_speed if is_key_down? :KB_KEY_A
  
  writeln 0, 0, :WHITE, :BLACK, "FPS: #{fps}"
end
