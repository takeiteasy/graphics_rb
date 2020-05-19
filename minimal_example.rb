#!/usr/bin/env ruby
require './rgi'

lena = Surface.new "lena.bmp"

run lena.width, lena.height do
  cls
  lena.blit 0, 0
end