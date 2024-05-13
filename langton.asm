
; Langton's ant
; RL rule set
; white cell : turn right, move forward, set black
; black cell : turn left, move forward, set white

                #org 0x2000                     ; set origin

                JAS _Clear                      ;
                MIB 0x00, _XPos                 ;
                MIB 0x00, _YPos                 ;
                JPS _Print "Langton's Ant", 0   ;
                JAS cr                          ;

                JAS draw_grid                   ;

                JPS _Prompt                     ;

; draw grid

draw_grid:      MIW 0x0000, xa                  ; grid is 400x240
                MIB 10, ya                      ;
                MIW 400, xb                     ;
                MIB 10, yb                      ;
                JAS _Line                       ;
                RTS                             ;

; print carriage return

cr:             LDI 0x0a                        ; carriage return
                JAS _PrintChar                  ;
                RTS                             ;

#mute

; OS labels

#org 0x0080     xa: steps: 0xffff               ; zero-page graphics interface (OS_SetPixel, OS_ClearPixel, OS_Line, OS_Rect)
                ya:        0xff
                xb:        0xffff
                yb:        0xff
                dx:        0xffff
                dy:        0xff
                bit:       0xff
                err:       0xffff

; storage

#org 0x0000

ant_x:          0xff                            ; ant x location
ant_y:          0xff                            ; ant y location
ant_direction:  0xff                            ; ant direction facing

grid_w:         40                              ; grid width
grid_h:         24                              ; grid height
cell_w:         10                              ; cell width
cell_h:         10                              ; cell height

#org 0x1000  grid:                              ; start of grid storage

; OS API

#org 0xf030     _ClearVRAM:                     ; Clears the video RAM including blanking areas
#org 0xf033     _Clear:                         ; Clears the visible video RAM (viewport)
#org 0xf036     _ClearRow:                      ; Clears the current row from cursor pos onwards
#org 0xf042     _PrintChar:                     ; Prints a char at the cursor pos (advancing)
#org 0xf045     _Print:                         ; Prints a zero-terminated immediate string
#org 0xf048     _PrintPtr:                      ; Prints a zero-terminated string at an address
#org 0xf04e     _SetPixel:                      ; Sets a pixel at position (x, y)
#org 0xf051     _Line:                          ; Draws a line using Bresenham’s algorithm
#org 0xf054     _Rect:                          ; Draws a rectangle at (x, y) of size (w, h)
#org 0xf057     _ClearPixel:                    ; Clears a pixel at position (x, y)
#org 0x00c0     _XPos:                          ; 1 byte: Horizontal cursor position (see _Print)
#org 0x00c1     _YPos:                          ; 1 byte: Vertical cursor position (see _Print)

#org 0xf003     _Prompt:
