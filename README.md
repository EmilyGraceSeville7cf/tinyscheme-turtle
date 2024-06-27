# Turtle

[![discuss.pixls.us](https://img.shields.io/badge/chat-Free%20Software%20Photography-ff69b4.svg?style=flat-square)](https://discuss.pixls.us/t/turtle-for-gimp/44067/4?u=emilygraceseville7cf)

## Description

Script to draw simple drawings.

![UI](UI.png)

## Installation

### Linux

- Place `turtle.scm` (referred as a **main script** later) in
  `~/.config/GIMP/2.10/scripts/`.

### Mac OS

This platform is not tested yet, instructions for it may vary.

### Windows

This platform is not tested yet, instructions for it may vary.

## Usage

### Linux

- Create a script `turtle-commands.scm` (referred as a **configuration script**
  later) in `~/.config/GIMP/2.10/scripts/` with the following content:

```lisp
; Don't change the variable name
(define turtle-configuration '( ; Don't remove this quote
    ; Turtle commands are placed here
))
```

- Create a script `turtle-theme.scm` (referred as a **theme configuration**
  **script** later) in `~/.config/GIMP/2.10/scripts/` with the following
  content:

```lisp
; Don't change the variable name,
; change RGB color values if other colors are needed
(define turtle-theme '((black (0 0 0)) ; Don't remove this quote
    (red (255 0 0))
    (green (0 255 0))
    (yellow (255 255 0))
    (blue (0 0 255))
    (magenta (255 0 138))
    (cyan (2 247 243))
    (gray (143 143 143))))

```

- Run **main script** via `File > Create > Turtle draw`.
- Select **configuration script** and **them configuration script** in the
  opened window.

### Mac OS

This platform is not tested yet, instructions for it may vary.

### Windows

This platform is not tested yet, instructions for it may vary.

## **configuration script** commands

Each command is a list.

| Command        | Description                                             | Arguments                                                                        | Example           |
| -------------- | ------------------------------------------------------- | -------------------------------------------------------------------------------- | ----------------- |
| `move-on`      | Move the turtle on a specific vector                    | `x` (integer) - a unit amount by X axis; `y` (integer) - a unit amount by Y axis | `(move-on 30 30)` |
| `move-to`      | Move the turtle to a specific point                     | `x` (integer) - a unit amount by X axis; `y` (integer) - a unit amount by Y axis | `(move-to 50 50)` |
| `forward`      | Move the turtle forward for a specific amount of units  | `value` (integer) - a unit amount                                                | `(forward 30)`    |
| `backward`     | Move the turtle backward for a specific amount of units | `value` (integer) - a unit amount                                                | `(backward 30)`   |
| `left`         | Rotate the turtle left at a specific amount of degrees  | `value` (integer) - a degree amount                                              | `(left 90)`       |
| `right`        | Rotate the turtle right at a specific amount of degrees | `value` (integer) - a degree amount                                              | `(right 90)`      |
| `up`           | Make turtle not draw on movements                       |                                                                                  |                   |
| `down`         | Make turtle draw on movements                           |                                                                                  |                   |
| `black`        | Change the turtle drawing color to black                |                                                                                  |                   |
| `red`          | Change the turtle drawing color to red                  |                                                                                  |                   |
| `green`        | Change the turtle drawing color to green                |                                                                                  |                   |
| `yellow`       | Change the turtle drawing color to yellow               |                                                                                  |                   |
| `blue`         | Change the turtle drawing color to blue                 |                                                                                  |                   |
| `magenta`      | Change the turtle drawing color to magenta              |                                                                                  |                   |
| `cyan`         | Change the turtle drawing color to cyan                 |                                                                                  |                   |
| `gray`         | Change the turtle drawing color to gray                 |                                                                                  |                   |
| `random-color` | Change the turtle drawing color to a random one         |                                                                                  |                   |

## **theme configuration script** options

Each color mapping from its name to an RGB value is a list.

| Color   | Description                           | Default       |
| ------- | ------------------------------------- | ------------- |
| black   | Color corresponding to a name black   | (0 0 0)       |
| red     | Color corresponding to a name red     | (255 0 0)     |
| green   | Color corresponding to a name green   | (0 255 0)     |
| yellow  | Color corresponding to a name yellow  | (255 255 0)   |
| blue    | Color corresponding to a name blue    | (0 0 255)     |
| magenta | Color corresponding to a name magenta | (255 0 138)   |
| cyan    | Color corresponding to a name cyan    | (2 247 243)   |
| gray    | Color corresponding to a name gray    | (143 143 143) |

## API

All functions starting with `turtle-internal-` are internal functions, all
other ones starting with `turtle-` are free to be used.

## Hints

- Use `(down)` at the beginning of the `turtle-configuration` to make sure
  image is drawn actually.
- Don't set the turtle drawing color before each movement command, it's better
  to set it once for several commands while it's the same.
- Separate logical blocks of commands by one space line, signifying different
  parts of the result image.

## Snippets

### Visual Studio Code

```json
{
    "move": {
        "prefix": "m",
        "description": "[m]ove the turtle for a specific amount of units",
        "body": "(${1|forward,backward|} ${2:units})"
    },
    "rotate": {
        "prefix": "r",
        "description": "[r]otate the turtle at a specific amount of degrees",
        "body": "(${1|left,right|} ${2:degrees})"
    },
    "color": {
        "prefix": "c",
        "description": "Change the turtle drawing [c]olor",
        "body": "(${1|black,red,green,yellow,blue,magenta,cyan,gray|})"
    }
}
```

## Example

Draw a red square 30x30:

```lisp
(define turtle-configuration '(
    (down)
    (red)
    (forward 30)
    (left 90)
    (forward 30)
    (left 90)
    (forward 30)
    (left 90)
    (forward 30)
))
```

Draw a multi-color cross sign 100x100:

```lisp
(define turtle-configuration '(
    (down)
    (red)
    (move-on 50 50)

    (up)
    (move-on -50 -50)

    (down)
    (green)
    (move-on -50 -50)

    (up)
    (move-on 50 50)

    (down)
    (blue)
    (move-on 50 -50)

    (up)
    (move-on -50 50)

    (down)
    (yellow)
    (move-on -50 50)
))
```
