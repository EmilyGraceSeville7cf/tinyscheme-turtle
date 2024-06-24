(define turtle-movement-commands '(forward backward))
(define turtle-rotation-commands '(left right))
(define turtle-color-commands '(black red green yellow blue magenta cyan gray))
(define turtle-pen-commands '(up down))
(define turtle-all-commands (append turtle-movement-commands
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

; Convert a list | vector to a string with a specific delimiter
(define (turtle-internal-sequence-to-string sequence delimiter)
    (let* ((new-sequence sequence))
        (if (vector? sequence)
            (set! new-sequence (vector->list sequence)))

        (cond
            ((null? new-sequence) "")
            ((null? (cdr new-sequence)) (car new-sequence))
            (else (string-append (car new-sequence)
                delimiter
                (turtle-internal-sequence-to-string (cdr new-sequence) delimiter))
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

; Check whether a command is a movement command
(define (turtle-internal-is-movement-command command)
    (turtle-internal-member? (car command) turtle-movement-commands)
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

; Check whether a command is not a movement command
(define (turtle-internal-is-not-movement-command command)
    (not (turtle-internal-is-movement-command command))
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

; Check whether a command has an argument
(define (turtle-internal-has-argument command)
    (not (null? (cdr command)))
)

; Check whether a command has no argument
(define (turtle-internal-has-no-argument command)
    (not (turtle-internal-has-argument command))
)

; Get a command argument
(define (turtle-internal-argument command)
    (cadr command)
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
        ((not (list? configuration)) (list (turtle-internal-make-error "type"
            "configuration" configuration "{{list}}")))
        (else (map (lambda (command)
            (let* ((command-string (turtle-to-string-with-delimiter command " ")))
                (cond
                    ((null? command) (turtle-internal-make-error "type" "configuration[...]"
                        "nothing" "{{list}}"))
                    ((not (list? command)) (turtle-internal-make-error "type"
                        "configuration[...]" command-string "{{list}}"))

                    ((turtle-internal-is-not-command command) (turtle-internal-make-error "type"
                        "configuration[...]" command-string (string-append "one of "
                        (turtle-to-string-with-delimiter turtle-all-commands " | "))))

                    ((and (or (turtle-internal-is-color-command command)
                        (turtle-internal-is-pen-command command)) (turtle-internal-has-argument
                        command)) (turtle-internal-make-error "argument" "configuration[...]"
                        command-string (string-append "no argument for "
                        (turtle-to-string-with-delimiter (append
                        turtle-color-commands turtle-pen-commands) " | "))))
                    ((and (or (turtle-internal-is-movement-command command)
                        (turtle-internal-is-rotation-command command))
                        (turtle-internal-has-no-argument command)) (turtle-internal-make-error
                        "argument" "configuration[...]" command-string (string-append
                        "argument for " (turtle-to-string-with-delimiter (append
                        turtle-movement-commands turtle-rotation-commands) " | "))))

                    ((and (or (turtle-internal-is-movement-command command)
                        (turtle-internal-is-rotation-command command))
                        (turtle-internal-has-no-argument command)) (turtle-internal-make-error
                        "argument" "configuration[...]" command-string
                        (string-append "argument for "
                        (turtle-to-string-with-delimiter (append
                        turtle-movement-commands turtle-rotation-commands) " | "))))
                    
                    ((and (or (turtle-internal-is-movement-command command)
                        (turtle-internal-is-rotation-command command)) (not (integer?
                        (turtle-internal-argument command)))) (turtle-internal-make-error "argument"
                        "configuration[...]" command-string (string-append
                        "integer argument for " (turtle-to-string-with-delimiter
                        (append turtle-movement-commands turtle-rotation-commands)
                        " | "))))
                    (else #t)
                )
            )) configuration))
    )
)

; Check whether a configuration is correct
(define (turtle-is-valid-configuration configuration)
    (turtle-internal-all? boolean? (turtle-validate-configuration configuration))
)

; Convert a color name to RGB
(define (turtle-internal-color-to-rgb color)
    (cond
        ((equal? 'black color) '(0 0 0))
        ((equal? 'red color) '(255 0 0))
        ((equal? 'green color) '(0 255 0))
        ((equal? 'yellow color) '(255 255 0))
        ((equal? 'blue color) '(0 0 255))
        ((equal? 'magenta color) '(255 0 138))
        ((equal? 'cyan color) '(2 247 243))
        ((equal? 'gray color) '(143 143 143))
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

; Draw with a turtle
(define (turtle-draw configuration-path x y color pen-state angle line-width image-width image-height)
    (load configuration-path)
    (set! color (nth color turtle-color-commands))
    (set! pen-state (nth pen-state turtle-pen-commands))
    (cond
        ((and (integer? x)
            (integer? y)
            (turtle-internal-member? color turtle-color-commands)
            (turtle-internal-member? pen-state turtle-pen-commands)
            (turtle-is-valid-configuration turtle-configuration))
            
            (let*
                (
                    (image (car (gimp-image-new image-width image-height
                        RGB)))
                    (layer (car (gimp-layer-new image image-width
                        image-height RGB-IMAGE "drawing" 100 NORMAL-MODE)))
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
                            (gimp-context-set-foreground (turtle-internal-color-to-rgb (car command)))
                            (print (string-append "🎨️ Color is set to " (symbol->string (car command)))))
                        ((turtle-internal-is-expected-command command 'left)
                            (set! angle (- angle (turtle-internal-argument command)))
                            (print (string-append "↪️ Turned to the left at " (number->string (turtle-internal-argument command)) " degrees")))
                        ((turtle-internal-is-expected-command command 'right)
                            (set! angle (+ angle (turtle-internal-argument command)))
                            (print (string-append "↪️ Turned to the right at " (number->string (turtle-internal-argument command)) " degrees")))
                        ((turtle-internal-is-expected-command command 'forward)
                            (let*
                                (
                                    (new-x (+ x (* (cos (turtle-internal-degrees-to-radians angle)) (turtle-internal-argument command))))
                                    (new-y (+ y (* (sin (turtle-internal-degrees-to-radians angle)) (turtle-internal-argument command))))
                                    (points (cons-array 4 'double))
                                )
                                
                                (aset points 0 x)
                                (aset points 1 y)
                                (aset points 2 new-x)
                                (aset points 3 new-y)
                                
                                (cond
                                    ((equal? pen-state 'down)
                                        (gimp-pencil layer 4 points)
                                        (print (string-append "📝️ Drew a line from " (turtle-internal-point-to-string x y) " to " (turtle-internal-point-to-string new-x new-y)))
                                    )
                                    (else (print "❌️✏️ Can't draw, pen is up"))
                                )
                                
                                (set! x new-x)
                                (set! y new-y)
                            )
                        )
                        ((turtle-internal-is-expected-command command 'backward)
                            (let*
                                (
                                    (new-x (- x (* (cos (turtle-internal-degrees-to-radians angle)) (turtle-internal-argument command))))
                                    (new-y (- y (* (sin (turtle-internal-degrees-to-radians angle)) (turtle-internal-argument command))))
                                    (points (cons-array 4 'double))
                                )
                                
                                (aset points 0 x)
                                (aset points 1 y)
                                (aset points 2 new-x)
                                (aset points 3 new-y)
                                
                                (cond
                                    ((equal? pen-state 'down)
                                        (gimp-pencil layer 4 points)
                                        (print (string-append "📝️ Drew a line from " (turtle-internal-point-to-string x y) " to " (turtle-internal-point-to-string new-x new-y)))
                                    )
                                    (else (print "❌️✏️ Can't draw, pen is up"))
                                )
                                
                                (set! x new-x)
                                (set! y new-y)
                            )
                        )
                    )
                ) turtle-configuration)
                
                (gimp-display-new image)
            )
            #t)
        (else
            (let*
                (
                    (message (string-append "Configuration in " configuration-path " or input parameters are incorrect"))
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
    SF-FILENAME "Path to a file with a 'turtle-configuration' variable with turtle commands" "/home/USER/.config/GIMP/2.10/scripts/NAME.scm"
    SF-ADJUSTMENT "Initial X coordinate" '(0 0 1000 1 5 0 SF-SPINNER)
    SF-ADJUSTMENT "Initial Y coordinate" '(0 0 1000 1 5 0 SF-SPINNER)
    SF-OPTION "Initial color" (map symbol->string turtle-color-commands)
    SF-OPTION "Initial pen state" (map symbol->string turtle-pen-commands)
    SF-ADJUSTMENT "Initial rotation angle" '(0 0 360 1 5 0 SF-SPINNER)
    SF-ADJUSTMENT "Line width" '(2 0 10 1 5 0 SF-SPINNER)
    SF-ADJUSTMENT "Image width" '(100 0 1000 1 5 0 SF-SPINNER)
    SF-ADJUSTMENT "Image height" '(100 0 1000 1 5 0 SF-SPINNER)
)

(script-fu-menu-register "turtle-draw" "<Image>/File/Create")
