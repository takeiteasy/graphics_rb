# graphics_rb

Ruby FFI binding for my [software rendering library](https://github.com/takeiteasy/graphics/). Also included `rgi.rb` is a framework to quickly prototype and test.

The bindings are generated dynamically by the make file using information from [ctags](https://github.com/universal-ctags/ctags). Since the underlying graphics library was made to be cross-platform, so is this. Currently the make file only works on OSX, but only needs tweeking to support Windows and Linux.

There are a few examples included, showing functionality of `rgi.rb` and raw `graphics.rb`. RGI was made to be zero-hassle to start making stuff. However, using the raw bindings isn't really difficult. The raycaster was adapted from an example on [lodev.org](https://lodev.org/cgtutor/files/raycaster_flat.cpp).

If you like this, check out [graphics](https://github.com/takeiteasy/graphics/).

## Screenshot

<p align="center">
  <img src="https://raw.githubusercontent.com/takeiteasy/graphics_rb/master/screenshot.png">
</p>


## License

```Created by Rory B. Bellows on 26/11/2017.
Copyright © 2017-2019 George Watson. All rights reserved.

Redistribution and use in source and binary forms, with or without
modification, are permitted provided that the following conditions are met:
*   Redistributions of source code must retain the above copyright
    notice, this list of conditions and the following disclaimer.
*   Redistributions in binary form must reproduce the above copyright
    notice, this list of conditions and the following disclaimer in the
    documentation and/or other materials provided with the distribution.
*   Neither the name of the <organization> nor the
    names of its contributors may be used to endorse or promote products
    derived from this software without specific prior written permission.
THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
ARE DISCLAIMED. IN NO EVENT SHALL GEORGE WATSON BE LIABLE FOR ANY
DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
(INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
(INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF
THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.```
