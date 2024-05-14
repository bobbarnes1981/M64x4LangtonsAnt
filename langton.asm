
; *********************************************************************************************
; Langton's ant
; *********************************************************************************************

; *********************************************************************************************
; viewport 400x240 pixels
; 40*24 cells = 960
; RL rule set
; white cell : turn right, move forward, set black
; black cell : turn left, move forward, set white
; *********************************************************************************************

; *********************************************************************************************
; TODO: make it faster
;       disable grid and draw cells smaller?
; *********************************************************************************************

; *********************************************************************************************
; Start
; *********************************************************************************************

                #org 0x2000                     ; set origin

                JAS clear_cells                 ; clear memory for cells

                MIW 0x2997, max_steps           ; set max steps (https://mathworld.wolfram.com/LangtonsAnt.html)
                ;MIW 0x0182, max_steps           ; set max steps (https://mathworld.wolfram.com/LangtonsAnt.html)
                MIW 0x0000, step_count          ; reset step count to zero
                MIW 0x00c8, ant_x               ; ant at x=200 pixels
                MIB 0x78, ant_y                 ; ant at y=120 pixels
                MIB 0, ant_direction            ; ant facing 0 (north)

                JAS _Clear                      ; clear display
                JAS draw_grid                   ; draw the grid outside loop, it is slow/flickers

                MIB 0x00, _XPos                 ; set print to x=0
                MIB 0x00, _YPos                 ; set print to y=0
                JPS _Print "Langton's Ant", 0   ; print the title
                LDI 0x0a                        ; load carriage return
                JAS _PrintChar                  ; print carriage return

loop:           JAS draw_cells                  ; draw the cells and do the ant logic

                INW step_count                  ; increment steps
                CBB max_steps+1, step_count+1   ; check MSB
                BNE loop                        ; continue loop
                CBB max_steps, step_count       ; check LSB
                BNE loop                        ; continue loop

                JPA _Prompt                     ; exit

; *********************************************************************************************
; draw grid subroutine : 400x240 pixels 10 pixels between lines
; *********************************************************************************************

draw_grid:

                MIB 0x0a, grid_current_y        ; set current y to 10
grid_y_loop:    MIW 0x0000, xa                  ; set line start x = 0
                MBB grid_current_y, ya          ; set line start y = grid_current_y
                MIW 0x0190, xb                  ; set line end x = 400
                MBB grid_current_y, yb          ; set line end y = grid_current_y
                JAS _Line                       ; draw line
                AIB 0x0a, grid_current_y        ; increment grid_current_y by 10
                CIB 0xf0, grid_current_y        ; compare to 0xf0 (decimal 240)
                BNE grid_y_loop                 ; loop if not zero

                MIW 0x000a, grid_current_x      ; set current x to 10
grid_x_loop:    MWV grid_current_x, xa          ; set line start x = grid_current_x
                MIB 0x00, ya                    ; set line start y = 0
                MWV grid_current_x, xb          ; set line end x = grid_current_x
                MIB 0xf0, yb                    ; set line end y = 240
                JAS _Line                       ; draw line
                AIW 0x0a, grid_current_x        ; increment grid_current_x by 10
                CIB 0x01, grid_current_x+1      ; compare MSB to 0x0186 MSB (+10) (decimal 390)
                BNE grid_x_loop                 ; loop if MSB not zero
                CIB 0x90, grid_current_x        ; compare LSB to 0x0186 LSB (+10) (decimal 390)
                BNE grid_x_loop                 ; loop if LSB not zero

                RTS                             ;

; *********************************************************************************************
; draw the cells subroutine : draw cell content and do the ant logic
; *********************************************************************************************

draw_cells:     MIW 0x1100, cell_addr           ; current cell array address
                MIB 0x00, grid_current_y        ; start at y 0

                ; start of row loop

cell_row_loop:  MIW 0x0000, grid_current_x      ; start at x 0

                ; start of col loop

cell_col_loop:  

                ; check if current grid is where the ant is

maybe_ant:      CBB ant_x+1, grid_current_x+1   ; compare ant to current x grid MSB
                BNE no_ant                      ;
                CBB ant_x, grid_current_x       ; compare ant to current x grid LSB
                BNE no_ant                      ;
                CBB ant_y, grid_current_y       ; compare ant to current y grid
                BNE no_ant                      ;

                ; set pixel location

                MWV grid_current_x, xa          ; set xa
                AIB 0x05, xa                    ; add 5 to xa
                MBB grid_current_y, ya          ; set ya
                AIW 0x05, ya                    ; add 5 to ya

                ; check cell pointer for cell colour

                LDR cell_addr                   ; load cell info byte
                CPI 0x00                        ; check if zero
                BEQ cell_black                  ;

                ; set pixel colour and update ant direction
                ;     only sets the pixel when the ant moves over the cell

cell_white:     MIR 0x00, cell_addr             ; update cell to black
                JAS _ClearPixel                 ; set pixel black
                INB ant_direction               ; update ant direction (turn right)
                CIB 0x04, ant_direction         ; compare for overflow
                BNE draw_ant                    ; skip if not overflow
                MIB 0x00, ant_direction         ; reset if overflow
                JPA draw_ant                    ;

cell_black:     MIR 0x01, cell_addr             ; update cell to white
                JAS _SetPixel                   ; set pixel white
                DEB ant_direction               ; update ant direction (turn left)
                CIB 0xff, ant_direction         ; compare for underflow
                BNE draw_ant                    ; skip if not underflow
                MIB 0x03, ant_direction         ; reset if underflow
                JPA draw_ant                    ;

                ; draw the ant

draw_ant:       ;MBB ant_x, xa                   ; do not draw ant, needs to be undrawn somehow
                ;MBB ant_x+1, xa+1               ;
                ;INW xa                          ;
                ;MBB ant_y, ya                   ;
                ;INB ya                          ;
                ;MIW 0x0008, xb                  ;
                ;MIB 0x08, yb                    ;
                ;JAS _Rect                       ;

                ; copy the ant location
                ;    we update the ant after the loops are done so it doesn't upset the logic

maybe_done:     MBB ant_x+1, nxt_x+1            ;
                MBB ant_x, nxt_x                ;
                MBB ant_y, nxt_y                ;

                ; check the ant direction and move the ant

ant_check_n:    CIB 0x00, ant_direction         ; check if facing north
                BNE ant_check_e                 ;
                SIB 0x0a, nxt_y                 ;
                CIB 0xf6, nxt_y                 ; is y 0xf6 (0-10) ?
                BNE no_ant                      ;
                MIB 0xe6, nxt_y                 ; set next y to 0xe6 (230)
                JPA no_ant                      ;
ant_check_e:    CIB 0x01, ant_direction         ; check if facing east
                BNE ant_check_s                 ;
                AIW 0x0a, nxt_x                 ; TODO: wrap screen
                JPA no_ant                      ;
ant_check_s:    CIB 0x02, ant_direction         ; check if facing south
                BNE ant_check_w                 ;
                AIB 0x0a, nxt_y                 ;
                CIB 0xf0, nxt_y                 ; is y 0xf0 (240) ?
                BNE no_ant                      ;
                MIB 0x00, nxt_y                 ; set next y to 0x00 (0)
                JPA no_ant                      ;
ant_check_w:    CIB 0x03, ant_direction         ; check if facing west, we shouldn't really need to check
                BNE no_ant                      ;
                SIW 0x0a, nxt_x                 ; TODO: wrap screen
                JPA no_ant                      ;

                ; increment the cell address pointer and check if we need to continue the loop

no_ant:         INW cell_addr                   ; increment cell address (pointer to cell info bytes)

                ; end of col loop

                AIW 0x0a, grid_current_x        ; increment grid_current_x by 10
                CIB 0x01, grid_current_x+1      ; compare MSB to 0x0186 MSB
                BNE cell_col_loop               ; continue loop
                CIB 0x90, grid_current_x        ; compare LSB to 0x0186 LSB (+10)
                BNE cell_col_loop               ; loop if MSB not zero

                ; end of row loop

                AIB 0x0a, grid_current_y        ; increment grid_current_y by 10
                CIB 0xf0, grid_current_y        ; compare to 0xf0 (250)
                BNE cell_row_loop               ; loop if LSB not zero

                ; update the ant location after the loop is finished

move_ant:       MBB nxt_x+1, ant_x+1            ; move the ant x MSB
                MBB nxt_x, ant_x                ; move the ant x LSB
                MBB nxt_y, ant_y                ; move the ant y

                RTS                             ;

; *********************************************************************************************
; clear the memory to hold the cells (all black cells)
; *********************************************************************************************

clear_cells:    MIW 0x1100, cell_addr           ; start form beginning of grid ram
                MIB 0x00, grid_current_y        ; start at y 0
clear_row_loop: MIW 0x0000, grid_current_x      ; start at x 0
clear_col_loop: MIR 0x00, cell_addr             ; set byte to 0x00
                INW cell_addr                   ; increment cell address
                AIW 0x0a, grid_current_x        ; increment grid_current_x by 10
                CIB 0x01, grid_current_x+1      ; compare MSB to 0x0186 MSB (+10) (decimal 400)
                BNE clear_col_loop              ; loop if MSB not zero
                CIB 0x90, grid_current_x        ; compare LSB to 0x0186 LSB (+10) (decimal 400)
                BNE clear_col_loop              ; loop if LSB not zero
                AIB 0x0a, grid_current_y        ; increment grid_current_y by 10
                CIB 0xf0, grid_current_y        ; compare to 0xf0 (250)
                BNE clear_row_loop              ; loop if not zero
                RTS

; *********************************************************************************************
; Data section
; *********************************************************************************************

#mute

; *********************************************************************************************
; OS labels
; *********************************************************************************************

#org 0x0080     xa: steps: 0xffff               ; zero-page graphics interface (OS_SetPixel, OS_ClearPixel, OS_Line, OS_Rect)
                ya:        0xff
                xb:        0xffff
                yb:        0xff
                dx:        0xffff
                dy:        0xff
                bit:       0xff
                err:       0xffff

; *********************************************************************************************
; storage
; *********************************************************************************************

#org 0x1000

ant_x:          0xffff                          ; ant x location
ant_y:          0xff                            ; ant y location
nxt_x:          0xffff                          ; next ant x location
nxt_y:          0xff                            ; next ant y location
ant_direction:  0xff                            ; ant direction facing

grid_current_x: 0xffff                          ; draw grid routine x
grid_current_y: 0xff                            ; draw grid routine y

cell_addr:      0xffff                          ; cell address

step_count:     0xffff                          ; step counter
max_steps:      0xffff                          ; max steps

#org 0x1100

grid:                                           ; start of grid storage (960 bytes)

; *********************************************************************************************
; OS API
; *********************************************************************************************

#org 0xf018     _ReadLine:                      ; Reads a command line into _ReadBuffer
#org 0xf030     _ClearVRAM:                     ; Clears the video RAM including blanking areas
#org 0xf033     _Clear:                         ; Clears the visible video RAM (viewport)
#org 0xf036     _ClearRow:                      ; Clears the current row from cursor pos onwards
#org 0xf042     _PrintChar:                     ; Prints a char at the cursor pos (advancing)
#org 0xf045     _Print:                         ; Prints a zero-terminated immediate string
#org 0xf048     _PrintPtr:                      ; Prints a zero-terminated string at an address
#org 0xf04b     _PrintHex:                      ; Prints a HEX number (advancing)
#org 0xf04e     _SetPixel:                      ; Sets a pixel at position (x, y)
#org 0xf051     _Line:                          ; Draws a line using Bresenham’s algorithm
#org 0xf054     _Rect:                          ; Draws a rectangle at (x, y) of size (w, h)
#org 0xf057     _ClearPixel:                    ; Clears a pixel at position (x, y)
#org 0x00c0     _XPos:                          ; 1 byte: Horizontal cursor position (see _Print)
#org 0x00c1     _YPos:                          ; 1 byte: Vertical cursor position (see _Print)
#org 0x00c9     _ReadPtr:                       ; 2 bytes: Command line parsing pointer
#org 0x00cd     _ReadBuffer:                    ; 2 bytes: Address of command line input buffer

#org 0xf003     _Prompt:
