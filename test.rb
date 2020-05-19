require './bgi'

test1 = Surface.new 100, 100
test1.fill :RED

test2 = Surface.new "/Users/roryb/Pictures/dev/lena.bmp"

run 640, 480 do
  cls
  if is_key_down? :KB_KEY_SPACE
    test2.blit 10, 22
  else
    test1.blit 10, 22
  end
  
  writeln 10, 10, :WHITE, :BLACK, "Hello World!"
end
