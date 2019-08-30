# Cobalt - ComputerCraft called you back.  
## Cobalt 2 has been released and therefore this project is no longer supported. [View Cobalt 2 here](https://github.com/ebernerd/cobalt-2).  
**Before you dive in, it is *very* much recommended that you read the [documentation](https://github.com/ebernerd/Cobalt/wiki). This will give you a lot of help!**

Install Cobalt by running `pastebin run h5h4fm3t` in your computer's shell.

Cobalt is a wrapper for ComputerCraft that allows it to run in a callback fashion, rather than an event-based way. Cobalt aims to make ComputerCraft similar to Love2D programming.

Cobalt also has optional packages, like [Cobalt-UI](https://github.com/ebernerd/Cobalt/wiki/Cobalt-UI), which adds a full UI library into your projects.

Here you can learn how to use the callback wrapper for ComputerCraft. If you've used [Love2D](http://love2d.org) before, you will be familiar with the way Cobalt works.

# Getting Started
To get started, you must include the Cobalt wrapper into your file. You can do that by downloading the main `cobalt` file, and placing it wherever you'd like in your ComputerCraft filesystem (you will need the absolute path of it to use it, however). Then, open your new Cobalt project (an empty file) and place:
```lua
local cobalt = dofile( "path/to/cobalt" )
```
You then need to include all of the callbacks:
```lua

function cobalt.update( dt )

end

function cobalt.draw()

end

function cobalt.mousepressed( x, y, button )

end

function cobalt.mousereleased( x, y, button )

end

function cobalt.keypressed( keycode, key )

end

function cobalt.keyreleased( keycode, key )
end

function cobalt.textinput( t )

end
```

After all your code is ready, you can validate it by trying to run it. If no errors pop up, your code is at least ready to run!

To initialize your program, make sure you include this snippet on the last line of your program:
```lua
cobalt.initLoop()
```

This starts the callback wrapper for Cobalt to work. You can learn how it works [here](https://github.com/ebernerd/Cobalt/wiki/cobalt.initLoop()).
