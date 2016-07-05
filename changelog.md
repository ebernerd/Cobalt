# Changelog
This is a list of all the changes made in Cobalt `1.1_0`.

## Additions
### Cobalt
+ Ported to Surface. This eliminates any screen flicker and tearing.
+ `cobalt.mouse`
  + `.isDown(button)` - returns if `button` is currently being pressed
### Cobalt UI
+ Inputs now have a `tabIndex` attribute. If not set, it defaults to the highest tab index of inputs in the parent container that share the same `state`.

## Modifications
### Cobalt
+ `cobalt.graphics.center` now wraps text to the width of the screen. No need for manually typing in `\n` anymore.
+ `cobalt.graphics` calls now are wrapped to draw to the main Cobalt surface, `cobalt.application.view`
+ `cobalt.keyboard.isDown(key)`, if `key` is left empty, will return true or false if _any_ key is down.

### Cobalt UI
+ `:setMargins(top, right, bottom, left)` is now `:setMargins(top, left)`, as bottom and right margins were never used.

## Removals
### Cobalt
+ `cobalt.graphics.centerInArea()`

### Cobalt UI
+ Bottom and right margins. They were pretty useless.


## Bug Fixes
### Cobalt
+ Fixed a few rounding issues

### Cobalt UI
+ Fixed percentage issues (using percentages with single digits, like `5%` or `05%`, or using `100%` no longer return incorrect values)
+ Percentages are now more precise, as they are in fraction form rather than rounded decimal form
+ 