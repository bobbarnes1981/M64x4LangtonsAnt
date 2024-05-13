
; Langton's ant
; RL rule set
; white cell : turn right, move forward, set black
; black cell : turn left, move forward, set white

        #org 0x2000                     ; set origin

        JPS _Print "Langton's Ant", 0   ;

#mute

; storage

#org 0x0000

ant_x:          0xff                    ; ant x location
ant_y:          0xff                    ; ant y location
ant_direction   0xff                    ; ant direction facing

0x1000  grid                            ; start of grid storage

; OS API

0xf045 _Print:                          ; Prints a zero-terminated immediate string
0xf048 _PrintPtr:                       ; Prints a zero-terminated string at an address
0xf04e _SetPixel:                       ; Sets a pixel at position (x, y)
0xf051 _Line:                           ; Draws a line using Bresenham’s algorithm
0xf054 _Rect:                           ; Draws a rectangle at (x, y) of size (w, h)
0xf057 _ClearPixel:                     ; Clears a pixel at position (x, y)
0x00c0 _XPos:                           ; 1 byte: Horizontal cursor position (see _Print)
0x00c1 _YPos:                           ; 1 byte: Vertical cursor position (see _Print)
