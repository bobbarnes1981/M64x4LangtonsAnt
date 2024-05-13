
; Langton's ant
; viewport 400x240 pixels
; 40*24 cells = 960
; RL rule set
; white cell : turn right, move forward, set black
; black cell : turn left, move forward, set white

; TODO: draw_cells and draw_grid should start from top left

                #org 0x2000                     ; set origin

                MIW 0x00c8, ant_x               ; ant at x 200 pixels
                MIB 0x78, ant_y                 ; ant at y 120 pixels
                MIB 0, ant_direction            ; ant facing 0 (north)

                JAS _Clear                      ;
                MIB 0x00, _XPos                 ;
                MIB 0x00, _YPos                 ;
                JPS _Print "Langton's Ant", 0   ;
                JAS cr                          ;

                JAS draw_grid                   ;
                JAS draw_cells                  ;
                JAS draw_ant                    ;

                JPS _Prompt                     ;

; draw grid (400x240)

                ; TODO: start at zero for x and y
draw_grid:      MIB 0xe6, grid_current_y        ; set start y 230
grid_row_loop:  MIW 0x0000, xa                  ; start x = 0
                MBB grid_current_y, ya          ; start y = grid_current_y
                MIW 0x0190, xb                  ; end x = 400
                MBB grid_current_y, yb          ; end y = grid_current_y
                JAS _Line                       ; draw line
                SIB 0x0a, grid_current_y        ; decrement grid_current_y by 10
                BNE grid_row_loop               ; loop if not zero

                MIW 0x0186, grid_current_x      ; set start x 390
grid_col_loop:  MWV grid_current_x, xa          ; start x = grid_current_x
                MIB 0x00, ya                    ; start y = 0
                MWV grid_current_x, xb          ; end x = grid_current_x
                MIB 0xf0, yb                    ; end y = 240
                JAS _Line                       ;
                SIW 0x0a, grid_current_x        ; decrement grid_current_x by 10
                BNE grid_col_loop               ; loop if MSB not zero
                LDB grid_current_x              ; Load LSB
                CPI 0x00                        ; compare to zero
                BNE grid_col_loop               ; loop if LSB not zero
                RTS                             ;

; draw the cells

draw_cells:     MIW 0x0000, cell_count          ; current cell number
                MIB 0x00, grid_current_y        ; start at y 0
cell_row_loop:  MIW 0x0000, grid_current_x      ; start at x 0
cell_col_loop:  MWV grid_current_x, xa          ; set xa
                AIB 0x05, xa                    ; add 5 to xa
                MBB grid_current_y, ya          ; set ya
                AIW 0x05, ya                    ; add 5 to ya
                JAS _SetPixel                   ; set pixel
                AIW 0x0a, grid_current_x        ; increment grid_current_x by 10
                CIB 0x01, grid_current_x+1      ; compare MSB to 0x0186 MSB
                BNE cell_col_loop               ; continue loop
                CIB 0x90, grid_current_x        ; compare LSB to 0x0186 LSB (+10)
                BNE cell_col_loop               ; continue loop
                AIB 0x0a, grid_current_y        ; increment grid_current_y by 10
                CIB 0xf0, grid_current_y        ; compare to 0xf0 (250)
                BNE cell_row_loop               ; continue loop
                RTS                             ;

; draw ant at current location

draw_ant:       MWV ant_x, xa                   ; left = ant_x
                INW xa                          ; increment x by 1
                MBB ant_y, ya                   ; top = ant_y
                INB ya                          ; increment y by 1
                MIW 0x0008, xb                  ; 8 wide
                MIB 0x08, yb                    ; 8 high
                JAS _Rect                       ; draw 'ant'
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

grid_current_x: 0xffff                          ; draw grid routine x
grid_current_y: 0xff                            ; draw grid routine y
cell_count:     0xffff                          ; count number of cells

grid:                                           ; start of grid storage (960 bytes)

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
