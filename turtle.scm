(define turtle-movement-commands '(forward backward))
(define turtle-rotation-commands '(left right))
(define turtle-color-commands '(black red green yellow blue magenta cyan gray))
(define turtle-pen-commands '(up down))
(define turtle-all-commands (append turtle-movement-commands
    turtle-rotation-commands
    turtle-color-commands
    turtle-pen-commands))

(define (turtle-sequence-to-string-internal sequence delimiter)
    (cond
        ((null? sequence) "")
        ((null? (cdr sequence)) (car sequence))
        (else (string-append (car sequence) delimiter
            (turtle-sequence-to-string-internal (cdr sequence) delimiter)))
    )
)

(define (turtle-sequence-to-string sequence delimiter)
    (string-append "(" (turtle-sequence-to-string-internal sequence delimiter)
        ")")
)

(define (turtle-to-string-with-delimiter value delimiter)
    (cond
        ((number? value) (number->string value))
        ((symbol? value) (symbol->string value))
        ((char? value) (string-append "character with " (number->string
            (char->integer value)) " code"))
        
        ((equal? value #t) "true")
        ((equal? value #f) "false")
        ((list? value) (turtle-sequence-to-string (map (lambda (value)
            (turtle-to-string-with-delimiter value delimiter)) value) delimiter))
        ((vector? value) "{{vector}}")
        (else value)
    )
)

(define (turtle-to-string value)
    (turtle-to-string-with-delimiter value ", ")
)

(define (turtle-make-error type source actual expected)
    (string-append
        "invalid " (turtle-to-string type)
        " for " (turtle-to-string source)
        " (expected: " (turtle-to-string expected)
        ", got: " (turtle-to-string actual) ")")
)

(define (member? value list)
    (cond
        ((null? list) #f)
        ((equal? value (car list)) #t)
        (else (member? value (cdr list)))
    )
)

(define (all? predicate list)
    (cond
        ((null? list) #t)
        (else (and (predicate (car list)) (all? predicate (cdr list))))
    )
)

(define (turtle-is-movement-command command)
    (if (list? command)
        (member? (car command) turtle-movement-commands)
        #f)
)

(define (turtle-is-rotation-command command)
    (if (list? command)
        (member? (car command) turtle-rotation-commands)
        #f)
)

(define (turtle-is-color-command command)
    (if (list? command)
        (member? (car command) turtle-color-commands)
        #f)
)

(define (turtle-is-pen-command command)
    (if (list? command)
        (member? (car command) turtle-pen-commands)
        #f)
)

(define (turtle-is-command command)
    (if (list? command)
        (member? (car command) turtle-all-commands)
        #f)
)

(define (turtle-is-not-movement-command command)
    (not (turtle-is-movement-command command))
)

(define (turtle-is-not-rotation-command command)
    (not (turtle-is-rotation-command command))
)

(define (turtle-is-not-color-command command)
    (not (turtle-is-color-command command))
)

(define (turtle-is-not-pen-command command)
    (not (turtle-is-pen-command command))
)

(define (turtle-is-not-command command)
    (not (turtle-is-command command))
)

(define (turtle-has-argument command)
    (if (list? command)
        (not (null? (cdr command)))
        #f)
)

(define (turtle-has-no-argument command)
    (not (turtle-has-argument command))
)

(define (turtle-argument command)
    (cadr command)
)

(define (turtle-is-expected-command actual expected)
    (if (list? actual)
        (equal? (car actual) expected)
        #f)
)

(define (turtle-validate-configuration configuration)
    (cond
        ((not (list? configuration)) (list (turtle-make-error "type"
            "configuration" configuration "{{list}}")))
        (else (map (lambda (command)
            (let* ((command-string (turtle-to-string-with-delimiter command " ")))
                (cond
                    ((null? command) (turtle-make-error "type" "configuration[...]"
                        "nothing" "{{list}}"))
                    ((not (list? command)) (turtle-make-error "type"
                        "configuration[...]" command-string "{{list}}"))

                    ((turtle-is-not-command command) (turtle-make-error "type"
                        "configuration[...]" command-string (string-append "one of "
                        (turtle-to-string-with-delimiter turtle-all-commands " | "))))

                    ((and (or (turtle-is-color-command command)
                        (turtle-is-pen-command command)) (turtle-has-argument
                        command)) (turtle-make-error "argument" "configuration[...]"
                        command-string (string-append "no argument for "
                        (turtle-to-string-with-delimiter (append
                        turtle-color-commands turtle-pen-commands) " | "))))
                    ((and (or (turtle-is-movement-command command)
                        (turtle-is-rotation-command command))
                        (turtle-has-no-argument command)) (turtle-make-error
                        "argument" "configuration[...]" command-string (string-append
                        "argument for " (turtle-to-string-with-delimiter (append
                        turtle-movement-commands turtle-rotation-commands) " | "))))

                    ((and (or (turtle-is-movement-command command)
                        (turtle-is-rotation-command command))
                        (turtle-has-no-argument command)) (turtle-make-error
                        "argument" "configuration[...]" command-string
                        (string-append "argument for "
                        (turtle-to-string-with-delimiter (append
                        turtle-movement-commands turtle-rotation-commands) " | "))))
                    
                    ((and (or (turtle-is-movement-command command)
                        (turtle-is-rotation-command command)) (not (integer?
                        (turtle-argument command)))) (turtle-make-error "argument"
                        "configuration[...]" command-string (string-append
                        "integer argument for " (turtle-to-string-with-delimiter
                        (append turtle-movement-commands turtle-rotation-commands)
                        " | "))))
                    (else #t)
                )
            )) configuration))
    )
)

(define (turtle-is-valid-configuration configuration)
    (all? boolean? (turtle-validate-configuration configuration))
)

(define (turtle-color-to-rgb color)
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

(define (turtle-degrees-to-radians-internal degrees)
    (* degrees (/ 3.1415926535897 180))
)

(define (turtle-point-to-string x y)
    (string-append "(" (turtle-to-string x) ", " (turtle-to-string y) ")")
)

(define (turtle-draw configuration-path x y color pen-state angle line-width image-width image-height)
    (load configuration-path)
    (set! color (nth color turtle-color-commands))
    (set! pen-state (nth pen-state turtle-pen-commands))
    (cond
        ((and (integer? x)
            (integer? y)
            (member? color turtle-color-commands)
            (member? pen-state turtle-pen-commands)
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
                        ((turtle-is-expected-command command 'down)
                            (set! pen-state 'down)
                            (print "✏️ Pen is put down"))
                        ((turtle-is-expected-command command 'up)
                            (set! pen-state 'up)
                            (print "✏️ Pen is up"))
                        ((turtle-is-color-command command)
                            (gimp-context-set-foreground (turtle-color-to-rgb (car command)))
                            (print (string-append "🎨️ Color is set to " (symbol->string (car command)))))
                        ((turtle-is-expected-command command 'left)
                            (set! angle (- angle (turtle-argument command)))
                            (print (string-append "↪️ Turned to the left at " (number->string (turtle-argument command)) " degrees")))
                        ((turtle-is-expected-command command 'right)
                            (set! angle (+ angle (turtle-argument command)))
                            (print (string-append "↪️ Turned to the right at " (number->string (turtle-argument command)) " degrees")))
                        ((turtle-is-expected-command command 'forward)
                            (if (equal? pen-state 'down)
                                (let*
                                    (
                                        (new-x (+ x (* (cos (turtle-degrees-to-radians-internal angle)) (turtle-argument command))))
                                        (new-y (+ y (* (sin (turtle-degrees-to-radians-internal angle)) (turtle-argument command))))
                                        (points (cons-array 4 'double))
                                    )
                                    
                                    (aset points 0 x)
                                    (aset points 1 y)
                                    (aset points 2 new-x)
                                    (aset points 3 new-y)
                                    (gimp-pencil layer 4 points)
                                    
                                    (print (string-append "📝️ Drew a line from " (turtle-point-to-string x y) " to " (turtle-point-to-string new-x new-y)))
                                    
                                    (set! x new-x)
                                    (set! y new-y)
                                )
                                (print "❌️✏️ Can't draw, pen is up")
                            )
                        )
                        ((turtle-is-expected-command command 'backward)
                            (if (equal? pen-state 'down)
                                (let*
                                    (
                                        (new-x (- x (* (cos (turtle-degrees-to-radians-internal angle)) (turtle-argument command))))
                                        (new-y (- y (* (sin (turtle-degrees-to-radians-internal angle)) (turtle-argument command))))
                                        (points (cons-array 4 'double))
                                    )
                                    
                                    (aset points 0 x)
                                    (aset points 1 y)
                                    (aset points 2 new-x)
                                    (aset points 3 new-y)
                                    (gimp-pencil layer 4 points)
                                    
                                    (print (string-append "📝️ Drew a line from " (turtle-point-to-string x y) " to " (turtle-point-to-string new-x new-y)))
                                    
                                    (set! x new-x)
                                    (set! y new-y)
                                )
                                (print "❌️✏️ Can't draw, pen is up")
                            )
                        )
                    )
                ) turtle-configuration)
                
                (gimp-display-new image)
            )
            #t)
        (else #f)
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
    ""                                      ;image type that the script works on
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
