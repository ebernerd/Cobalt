# Changelog
This is a list of all the changes made in Cobalt `1.1_2`.

## Additions
### Cobalt
+ Error handling. You can see an example [here](http://i.imgur.com/82mJYaT.gif)
### Cobalt UI
+ None

## Modifications
### Cobalt
+ `cobalt.graphics.center( text, y, offset, backColour, colour )` - syntax changed to `( text, y, offset, lim, backColour, colour)`. `lim` is a limit, so you can set an offset and a limit to change where the centering is allowed to happen.
### Cobalt UI
+ None
## Removals
### Cobalt
+ None
### Cobalt UI
+ None

## Bug Fixes
### Cobalt
+ Version checking printed the incorrect version number.
### Cobalt UI
+ Fixed Textareas not allowing percentages for the `h` attribute.