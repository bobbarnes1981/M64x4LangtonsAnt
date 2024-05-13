
; Langton's ant
; RL rule set
; white cell : turn right, move forward, set black
; black cell : turn left, move forward, set white

                #org 0x2000                     ; set origin

                MIB 40, grid_w                  ; grid 40 cells wide
                MIB 24, grid_h                  ; grid 24 cell high
                MIB 10, cell_w                  ; cell 10 pixels wide
                MIB 10, cell_h                  ; cell 10 pixels heigh
                MIB 20, ant_x                   ; ant in middle of x
                MIB 12, ant_y                   ; and in middle of y
                MIB 0, ant_direction            ; ant facing 0 (north)

                JAS _Clear                      ;
                MIB 0x00, _XPos                 ;
                MIB 0x00, _YPos                 ;
                JPS _Print "Langton's Ant", 0   ;
                JAS cr                          ;

                JAS draw_grid                   ;

                JPS _Prompt                     ;

; draw grid (400x240)

draw_grid:      MIB 0xe6, current_row           ; set start row 230
grid_row_loop:  MIW 0x0000, xa                  ; start x = 0
                MBB current_row, ya             ; start y = current_row
                MIW 0x0190, xb                  ; end x = 400
                MBB current_row, yb             ; end y = current_row
                JAS _Line                       ; draw line
                SIB 0x0a, current_row           ; decrement current_row by 10
                BNE grid_row_loop               ; loop if not zero

                MIW 0x0186, current_col         ; set start col 390
grid_col_loop:  MWV current_col, xa             ; start x = current_col
                MIB 0x00, ya                    ; start y = 0
                MWV current_col, xb             ; end x = current_col
                MIB 0xf0, yb                    ; end y = 240
                JAS _Line                       ;
                SIW 0x0a, current_col           ; decrement current_col by 10
                BNE grid_col_loop               ; loop if MSB not zero
                LDB current_col                 ; Load LSB
                CPI 0x00                        ; compare to zero
                BNE grid_col_loop               ; loop if LSB not zero
                RTS                             ;

; print carriage return

cr:             LDI 0x0a                        ; carriage return
                JAS _PrintChar                  ;
                RTS                             ;

        ;spin:   JPA spin                        ; DEBUG

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

#org 0x1000

ant_x:          0xffff                          ; ant x location
ant_y:          0xff                            ; ant y location
ant_direction:  0xff                            ; ant direction facing

grid_w:         0xffff                          ; grid width
grid_h:         0xff                            ; grid height

cell_w:         0xff                            ; cell width
cell_h:         0xff                            ; cell height

current_col:    0xffff                          ; draw grid routine col
current_row:    0xff                            ; draw grid routine row

grid:                                           ; start of grid storage

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
