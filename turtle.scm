(define turtle-vector-movement-commands '(move-to move-on))
(define turtle-movement-commands '(forward backward))

(define turtle-special-movement-commands '(move-to-center
    move-to-top-left
    move-to-top-middle
    move-to-top-right
    move-to-middle-right
    move-to-bottom-right
    move-to-bottom-middle
    move-to-bottom-left
    move-to-middle-left))

(define turtle-rotation-commands '(left right))

(define turtle-color-commands '(black
    red
    green
    yellow
    blue
    magenta
    cyan
    gray
    random-color))

(define turtle-pen-commands '(up down))

(define turtle-all-commands (append turtle-vector-movement-commands
    turtle-movement-commands
    turtle-special-movement-commands
    turtle-rotation-commands
    turtle-color-commands
    turtle-pen-commands))


; Check whether a value in a list
(define (turtle-internal-member? value list)
    (if (not (equal? (member value list) #f))
        #t
        #f)
)

; Check whether all list items conform a predicate
(define (turtle-internal-all? predicate list)
    (cond
        ((null? list) #t)
        (else (and
            (predicate (car list))
            (turtle-internal-all? predicate (cdr list)))
        )
    )
)

; Get a first item matching a predicate or a default value if such an item doesn't exist
(define (turtle-internal-first-match-or-default predicate default list)
    (cond
        ((null? list) default)
        (else
            (cond
                ((predicate (car list)) (car list))
                (else (turtle-internal-first-match-or-default predicate
                    default
                    (cdr list)))
            )
        )
    )
)

; Convert a list | vector to a string with a specific delimiter
(define (turtle-internal-sequence-to-string sequence delimiter)
    (let* (
            (new-sequence sequence)
        )

        (if (vector? sequence)
            (set! new-sequence (vector->list sequence)))

        (cond
            ((null? new-sequence) "")
            ((null? (cdr new-sequence)) (car new-sequence))
            (else (string-append (car new-sequence)
                delimiter
                (turtle-internal-sequence-to-string (cdr new-sequence)
                    delimiter))
            )
        )
    )
)

; Convert a list | vector to a string
(define (turtle-sequence-to-string sequence delimiter)
    (string-append "("
        (turtle-internal-sequence-to-string sequence delimiter)
        ")")
)

; Convert a value to a string with a specific delimiter
(define (turtle-to-string-with-delimiter value delimiter)
    (cond
        ((number? value) (number->string value))
        ((symbol? value) (symbol->string value))
        
        ((char? value) (string-append "character with "
            (number->string (char->integer value)) " code"))
        
        ((equal? value #t) "true")
        ((equal? value #f) "false")

        ((list? value) (turtle-sequence-to-string
            (map (lambda (value)
                (turtle-to-string-with-delimiter value delimiter))
                value)
            delimiter)
        )

        ((vector? value) (turtle-sequence-to-string
            (map (lambda (value)
                (turtle-to-string-with-delimiter value delimiter))
                value)
            delimiter)
        )

        (else value)
    )
)

; Convert a value to a string
(define (turtle-to-string value)
    (turtle-to-string-with-delimiter value ", ")
)

; Create a new error message
(define (turtle-internal-make-error type source actual expected)
    (string-append "Invalid " (turtle-to-string type)
        " for " (turtle-to-string source)
        " (expected: " (turtle-to-string expected)
        ", got: " (turtle-to-string actual) ")")
)

; Check whether a command is a vector movement command
(define (turtle-internal-is-vector-movement-command command)
    (turtle-internal-member? (car command) turtle-vector-movement-commands)
)

; Check whether a command is a movement command
(define (turtle-internal-is-movement-command command)
    (turtle-internal-member? (car command) turtle-movement-commands)
)

; Check whether a command is a special movement command
(define (turtle-internal-is-special-movement-command command)
    (turtle-internal-member? (car command) turtle-special-movement-commands)
)

; Check whether a command is a rotation command
(define (turtle-internal-is-rotation-command command)
    (turtle-internal-member? (car command) turtle-rotation-commands)
)

; Check whether a command is a color changing command
(define (turtle-internal-is-color-command command)
    (turtle-internal-member? (car command) turtle-color-commands)
)

; Check whether a command is a pen state changing command
(define (turtle-internal-is-pen-command command)
    (turtle-internal-member? (car command) turtle-pen-commands)
)

; Check whether a command is a turtle command
(define (turtle-internal-is-command command)
    (turtle-internal-member? (car command) turtle-all-commands)
)

; Check whether a command is not a vector movement command
(define (turtle-internal-is-not-vector-movement-command command)
    (not (turtle-internal-is-vector-movement-command command))
)

; Check whether a command is not a movement command
(define (turtle-internal-is-not-movement-command command)
    (not (turtle-internal-is-movement-command command))
)

; Check whether a command is not a special movement command
(define (turtle-internal-is-not-special-movement-command command)
    (not (turtle-internal-is-special-movement-command command))
)

; Check whether a command is not a rotation command
(define (turtle-internal-is-not-rotation-command command)
    (not (turtle-internal-is-rotation-command command))
)

; Check whether a command is not a color changing command
(define (turtle-internal-is-not-color-command command)
    (not (turtle-internal-is-color-command command))
)

; Check whether a command is not a pen state changing command
(define (turtle-internal-is-not-pen-command command)
    (not (turtle-internal-is-pen-command command))
)

; Check whether a command is not a turtle command
(define (turtle-internal-is-not-command command)
    (not (turtle-internal-is-command command))
)

; Check whether a command has a specific amount of arguments
(define (turtle-internal-has-arguments command count)
    (= (length (cdr command)) count)
)

; Check whether a command has any arguments
(define (turtle-internal-has-any-arguments command)
    (not (null? (cdr command)))
)

; Check whether a command has no arguments
(define (turtle-internal-has-no-arguments command)
    (turtle-internal-has-arguments command 0)
)

; Get a command argument
(define (turtle-internal-argument command index)
    (nth index (cdr command))
)

; Check whether a command is an expected one
(define (turtle-internal-is-expected-command actual expected)
    (if (list? actual)
        (equal? (car actual) expected)
        #f)
)

; Check whether a configuration is correct
(define (turtle-validate-configuration configuration)
    (cond
        ((not (list? configuration)) (list
            (turtle-internal-make-error "type"
                "configuration"
                configuration
                "{{list}}"
            ))
        )

        (else (map (lambda (command)
            (let* (
                    (command-string
                        (turtle-to-string-with-delimiter command " "))
                )

                (cond
                    ((null? command) (turtle-internal-make-error "type"
                        "configuration[...]"
                        "nothing"
                        "{{list}}"))
                    
                    ((not (list? command)) (turtle-internal-make-error "type"
                        "configuration[...]"
                        command-string
                        "{{list}}"))

                    ((turtle-internal-is-not-command command)
                        (turtle-internal-make-error "type"
                            "configuration[...]"
                            command-string
                            (string-append "one of "
                                (turtle-to-string-with-delimiter
                                    turtle-all-commands " | "))))

                    ((and (or (turtle-internal-is-color-command command)
                        (turtle-internal-is-pen-command command)
                        (turtle-internal-is-special-movement-command command))
                        (turtle-internal-has-any-arguments command))

                        (turtle-internal-make-error "argument"
                            "configuration[...]"
                            command-string
                            (string-append "no argument for "
                                (turtle-to-string-with-delimiter (append
                                    turtle-color-commands
                                    turtle-pen-commands
                                    turtle-special-movement-commands)
                                    " | "))))
                    
                    ((and (or (turtle-internal-is-movement-command command)
                        (turtle-internal-is-rotation-command command))
                        (not (turtle-internal-has-arguments command 1)))
                        
                        (turtle-internal-make-error "argument"
                            "configuration[...]"
                            command-string
                            (string-append "one argument for "
                                (turtle-to-string-with-delimiter (append
                                    turtle-movement-commands
                                    turtle-rotation-commands)
                                    " | "))))
                    
                    ((and (turtle-internal-is-vector-movement-command command)
                        (not (turtle-internal-has-arguments command 2)))
                        
                        (turtle-internal-make-error "argument"
                            "configuration[...]"
                            command-string
                            (string-append "two arguments for "
                                (turtle-to-string-with-delimiter (append
                                    turtle-movement-commands
                                    turtle-rotation-commands)
                                    " | "))))

                    ((and (or (turtle-internal-is-movement-command command)
                        (turtle-internal-is-rotation-command command))
                        (not (integer? (turtle-internal-argument command 0))))
                        
                        (turtle-internal-make-error "argument"
                            "configuration[...]"
                            command-string
                            (string-append "integer argument for "
                                (turtle-to-string-with-delimiter
                                    (append turtle-movement-commands
                                        turtle-rotation-commands)
                                    " | "))))
                    
                    ((and (turtle-internal-is-vector-movement-command command)
                        (or
                            (not (integer? (turtle-internal-argument command 0)))
                            (not (integer? (turtle-internal-argument command 1)))
                        ))
                        
                        (turtle-internal-make-error "argument"
                            "configuration[...]"
                            command-string
                            (string-append "integer arguments for "
                                (turtle-to-string-with-delimiter
                                    turtle-vector-movement-commands
                                    " | "))))

                    (else #t)
                )
            )) configuration))
    )
)

; Check whether a configuration is correct
(define (turtle-is-valid-configuration configuration)
    (turtle-internal-all? boolean?
        (turtle-validate-configuration configuration))
)

; Convert a color name to RGB
(define (turtle-internal-color-to-rgb color)
    (cond
        ((equal? 'random-color color) (turtle-internal-color-to-rgb
            (nth (rand (- (length turtle-color-commands) 1))
            turtle-color-commands)))
        ((turtle-internal-is-color-command (list color)) (cadr
            (assoc color turtle-theme))
        )
        (else #f) 
    )
)

; Convert degrees to radians
(define (turtle-internal-degrees-to-radians degrees)
    (* degrees (/ 3.1415926535897 180))
)

; Convert a point to a string
(define (turtle-internal-point-to-string x y)
    (string-append "(" (turtle-to-string x) ", " (turtle-to-string y) ")")
)

; Draw line or move
(define (turtle-internal-draw-or-move-to from-x
    from-y
    to-x
    to-y
    pen-state
    layer)

    (let* (
            (points (cons-array 4 'double))
        )
        
        (aset points 0 from-x)
        (aset points 1 from-y)
        (aset points 2 to-x)
        (aset points 3 to-y)
        
        (cond
            ((equal? pen-state 'down)
                (gimp-pencil layer 4 points)
                (print
                    (string-append
                        "📝️ Drew a line from "
                        (turtle-internal-point-to-string
                            from-x
                            from-y)
                        " to "
                        (turtle-internal-point-to-string
                            to-x
                            to-y)))
            )
            (else (print "❌️✏️ Can't draw, pen is up"))
        )
    )
)

; Draw with a turtle
(define (turtle-draw configuration-path
    theme-path
    x
    y
    color
    pen-state
    angle
    line-width
    image-width
    image-height)

    (load configuration-path)
    (load theme-path)
    (set! color (nth color turtle-color-commands))
    (set! pen-state (nth pen-state turtle-pen-commands))
    (srand (realtime))

    (cond
        ((and (integer? x)
            (integer? y)
            (turtle-internal-member? color turtle-color-commands)
            (turtle-internal-member? pen-state turtle-pen-commands)
            (turtle-is-valid-configuration turtle-configuration))
            
            (let* (
                    (image (car (gimp-image-new image-width image-height RGB)))
                    (layer (car
                        (gimp-layer-new image
                            image-width
                            image-height
                            RGB-IMAGE
                            "drawing"
                            100
                            NORMAL-MODE)))
                    (image-width (car (gimp-image-width image)))
                    (image-height (car (gimp-image-height image)))
                    (image-width-half (/ image-width 2))
                    (image-height-half (/ image-height 2))
                )
                
                (gimp-image-insert-layer image layer 0 0)
                (gimp-context-set-brush-size line-width)
                (gimp-drawable-fill layer WHITE-FILL)
                
                (map (lambda (command)
                    (cond
                        ((turtle-internal-is-expected-command command 'down)
                            (set! pen-state 'down)
                            (print "✏️ Pen is put down"))
                        
                        ((turtle-internal-is-expected-command command 'up)
                            (set! pen-state 'up)
                            (print "✏️ Pen is up"))
                        
                        ((turtle-internal-is-color-command command)
                            (gimp-context-set-foreground
                                (turtle-internal-color-to-rgb (car command)))
                            (print (string-append "🎨️ Color is set to "
                                (symbol->string (car command)))))
                        
                        ((turtle-internal-is-expected-command command 'left)
                            (set! angle (- angle
                                (turtle-internal-argument command 0)))
                            (print (string-append "↪️ Turned to the left at "
                                (number->string
                                    (turtle-internal-argument command 0))
                                " degrees")))
                        
                        ((turtle-internal-is-expected-command command 'right)
                            (set! angle (+ angle
                                (turtle-internal-argument command 0)))
                            (print (string-append "↪️ Turned to the right at "
                                (number->string
                                    (turtle-internal-argument command 0))
                                " degrees")))
                        
                        ((turtle-internal-is-expected-command command
                            'forward)
                        
                            (let* (
                                    (new-x (+ x
                                        (*
                                            (cos
                                                (turtle-internal-degrees-to-radians
                                                    angle))
                                            (turtle-internal-argument command
                                                0))))

                                    (new-y (+ y
                                        (*
                                            (sin
                                                (turtle-internal-degrees-to-radians
                                                    angle))
                                            (turtle-internal-argument command
                                                0))))
                                )
                            
                                (turtle-internal-draw-or-move-to x
                                    y
                                    new-x
                                    new-y
                                    pen-state
                                    layer)
                                
                                (set! x new-x)
                                (set! y new-y)
                            )
                        )

                        ((turtle-internal-is-expected-command command
                            'backward)
                        
                            (let* (
                                    (new-x (- x
                                        (*
                                            (cos
                                                (turtle-internal-degrees-to-radians
                                                    angle))
                                            (turtle-internal-argument command
                                                0))))

                                    (new-y (- y
                                        (*
                                            (sin
                                                (turtle-internal-degrees-to-radians
                                                    angle))
                                            (turtle-internal-argument command
                                                0))))
                                )
                            
                                (turtle-internal-draw-or-move-to x
                                    y
                                    new-x
                                    new-y
                                    pen-state
                                    layer)
                                
                                (set! x new-x)
                                (set! y new-y)
                            )
                        )

                        ((turtle-internal-is-expected-command command
                            'move-on)
                        
                            (let* (
                                    (new-x (+ x (turtle-internal-argument
                                        command
                                        0)))

                                    (new-y (+ y (turtle-internal-argument
                                        command
                                        1)))
                                )
                            
                                (turtle-internal-draw-or-move-to x
                                    y
                                    new-x
                                    new-y
                                    pen-state
                                    layer)
                                
                                (set! x new-x)
                                (set! y new-y)
                            )
                        )

                        ((turtle-internal-is-expected-command command
                            'move-to)
                        
                            (let* (
                                    (new-x (turtle-internal-argument
                                        command
                                        0))

                                    (new-y (turtle-internal-argument
                                        command
                                        1))
                                )
                            
                                (turtle-internal-draw-or-move-to x
                                    y
                                    new-x
                                    new-y
                                    pen-state
                                    layer)
                                
                                (set! x new-x)
                                (set! y new-y)
                            )
                        )

                        ((turtle-internal-is-expected-command command
                            'move-to-center)
                        
                            (turtle-internal-draw-or-move-to x
                                y
                                image-width-half
                                image-height-half
                                pen-state
                                layer)
                            
                            (set! x image-width-half)
                            (set! y image-height-half)
                        )

                        ((turtle-internal-is-expected-command command
                            'move-to-top-left)
                        
                            (turtle-internal-draw-or-move-to x
                                y
                                0
                                0
                                pen-state
                                layer)
                            
                            (set! x 0)
                            (set! y 0)
                        )

                        ((turtle-internal-is-expected-command command
                            'move-to-top-middle)
                        
                            (turtle-internal-draw-or-move-to x
                                y
                                image-width-half
                                0
                                pen-state
                                layer)
                            
                            (set! x image-width-half)
                            (set! y 0)
                        )

                        ((turtle-internal-is-expected-command command
                            'move-to-top-right)
                        
                            (turtle-internal-draw-or-move-to x
                                y
                                image-width
                                0
                                pen-state
                                layer)
                            
                            (set! x image-width)
                            (set! y 0)
                        )

                        ((turtle-internal-is-expected-command command
                            'move-to-middle-right)
                        
                            (turtle-internal-draw-or-move-to x
                                y
                                image-width
                                image-height-half
                                pen-state
                                layer)
                            
                            (set! x image-width)
                            (set! y image-height-half)
                        )

                        ((turtle-internal-is-expected-command command
                            'move-to-bottom-right)
                        
                            (turtle-internal-draw-or-move-to x
                                y
                                image-width
                                image-height
                                pen-state
                                layer)
                            
                            (set! x image-width)
                            (set! y image-height)
                        )

                        ((turtle-internal-is-expected-command command
                            'move-to-bottom-middle)
                        
                            (turtle-internal-draw-or-move-to x
                                y
                                image-width-half
                                image-height
                                pen-state
                                layer)
                            
                            (set! x image-width-half)
                            (set! y image-height)
                        )

                        ((turtle-internal-is-expected-command command
                            'move-to-bottom-left)
                        
                            (turtle-internal-draw-or-move-to x
                                y
                                0
                                image-height
                                pen-state
                                layer)
                            
                            (set! x 0)
                            (set! y image-height)
                        )

                        ((turtle-internal-is-expected-command command
                            'move-to-middle-left)
                        
                            (turtle-internal-draw-or-move-to x
                                y
                                0
                                image-height-half
                                pen-state
                                layer)
                            
                            (set! x 0)
                            (set! y image-height-half)
                        )
                    )
                ) turtle-configuration)
                
                (gimp-display-new image)
            )
            #t)
        (else
            (let* (
                    (first-error (turtle-internal-first-match-or-default
                        string?
                        ""
                        (turtle-validate-configuration turtle-configuration)))
                    (message
                        "One or more input parameters for turtle-draw are incorrect")
                )
                
                (if (not (equal? first-error ""))
                    (set! message (string-append "One or more commands in "
                        configuration-path
                        " are invalid, the first error is: "
                        first-error))
                )

                (print message)
                (gimp-message message)
            )

            #f
        )
    )
)


(script-fu-register
    "turtle-draw"
    "Turtle draw"
    (string-append "Creates a simple drawing with a turtle commands.\
\
Available commands: " (turtle-to-string turtle-all-commands) ".\
- " (turtle-to-string turtle-movement-commands) " require a single argument denoting amount of pixels to move the turtle on.\
- " (turtle-to-string turtle-rotation-commands) " require a single argument denoting amount of degrees to rotate the turtle at.\
- Other commands don't require any argument.\
\
All commands should be put in a list like this: '((red) (forward 30) (left 90) (forward 30))"
)
    "Maisa Unbelievable"
    "copyright 2024, Maisa Unbelievable"
    "June 17, 2024"
    ""
    SF-FILENAME "Path to a configuration file\
with a 'turtle-configuration' variable\
with turtle commands" "/home/USER/.config/GIMP/2.10/scripts/NAME.scm"
    SF-FILENAME "Path to a configuration file\
with a 'turtle-theme' variable\
with turtle colors" "/home/USER/.config/GIMP/2.10/scripts/NAME.scm"
    SF-ADJUSTMENT "Initial X coordinate" '(50 0 1000 1 5 0 SF-SPINNER)
    SF-ADJUSTMENT "Initial Y coordinate" '(50 0 1000 1 5 0 SF-SPINNER)
    SF-OPTION "Initial color" (map symbol->string turtle-color-commands)
    SF-OPTION "Initial pen state" (map symbol->string turtle-pen-commands)
    SF-ADJUSTMENT "Initial rotation angle" '(0 0 360 1 5 0 SF-SPINNER)
    SF-ADJUSTMENT "Line width" '(2 0 10 1 5 0 SF-SPINNER)
    SF-ADJUSTMENT "Image width" '(100 0 1000 1 5 0 SF-SPINNER)
    SF-ADJUSTMENT "Image height" '(100 0 1000 1 5 0 SF-SPINNER)
)

(script-fu-menu-register "turtle-draw" "<Image>/File/Create")
