PRO wtc_ozonesonde_gui

compile_opt idl2

;error catcher:
CATCH, theError
IF theError NE 0 THEN BEGIN
CATCH, /cancel
HELP, /LAST_MESSAGE, OUTPUT=errMsg
FOR i=0, N_ELEMENTS(errMsg)-1 DO print, errMsg[i]
RETURN
ENDIF

;some defaults:
plot_xsize = 500
plot_ysize = 500

;define top level base
tlb = WIDGET_BASE(COL=2, TITLE='Ozonesonde Analyzer' $
                  , Mbar = menubarID, UNAME='main_base')
                  
;fill the "first" column
base1ID = WIDGET_BASE(tlb, COL=1)
;variable selector (combobox)
id = WIDGET_COMBOBOX(base1ID, VALUE='Select a variable', UNAME='combo_var')
WIDGET_CONTROL, id, SET_UVALUE=0 ;set the user value to keep track of index
;time of scans (list)
id = WIDGET_LIST(base1ID, VALUE='Time of scans', UNAME='list_time', YSIZE=10)

;fill the "second" column
base2ID = WIDGET_BASE(tlb, COL=1)
;draw widget
id = WIDGET_DRAW(base2ID, XSIZE=plot_xsize, YSIZE=plot_ysize, $
UNAME='draw_radar', /BUTTON_EVENTS, $
EVENT_PRO='pmb_radar_gui_draw_events')
;output box (for cursor coords)
id = WIDGET_LABEL(base2ID, VALUE=STRING(' ', FORMAT='(A25)'), $
/ALIGN_RIGHT, UNAME='label_info')
id = WIDGET_LABEL(base2ID, VALUE=STRING(' ', FORMAT='(A25)')) ;spacer label

;make menubar
fileID = WIDGET_BUTTON(menubarID, VALUE='File', /MENU)
id = WIDGET_BUTTON(fileID, VALUE='Load Gridded Radar Files', UNAME='but_load')
id = WIDGET_BUTTON(fileID, VALUE='Quit', UNAME='but_quit')

;realize the GUI
WIDGET_CONTROL, tlb, /REALIZE

END