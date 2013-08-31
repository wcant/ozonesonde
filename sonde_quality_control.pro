FUNCTION read_de1, file

  OPENR, lun, file, /GET_LUN
  nlines=FILE_LINES(file)
  dummy=STRARR(nlines)
  READF, lun, dummy
  FREE_LUN, lun
;Parameters to keep track of:
;1. Flight number (fltnum)
;2. Date  (date)
;3. Time  (time)
;4. Longitude (lon)
;5. Latitude  (lat)
;6. Time Zone (GMT/CST) (time_zone)
;7. Launch altitude (launch_alt)
;8. Surface Pressure  (sfc_press)
;9. Surface temp  (sfc_temp)
;10 Surface humidity  (sfc_hum)
;11. Total ozone column (o3col)
;12. 100 ml flow rate time  (flowrate_100ml)
;13. Lab temp for flowrate  (flowrate_temp)
;14. Lab humidity for flowrate  (flowrate_hum)
;15. Flowrate correction  (flowrate_cor)
;16. Background current   (bgcurrent)
;17. Bg current, different versions sometimes output the bg in a different field, so this is the same as 16.

  search_strings=['Flight number', 'Date [GMT]', 'Time [GMT]', 'Longitude', 'Latitude'  $
                  , 'Time stamp', 'Launch altitude', 'Surface Pressure', 'Surface temperature'  $
                  , 'Surface humidity', 'Total ozone column', 'Time (sec) to pump 100 ml' $
                  , 'Lab temp. for flowrate', 'Lab humidity for flowrate', 'Dry flowrate correction' $
                  , 'Background current', 'Prep background']  ;background current and prep background are the same thing, but different versions of the 
                                                              ;retrieval program output them differently.  So whichever is non-zero should be used.
  data=STRARR(N_ELEMENTS(search_strings))
  FOR i=0, N_ELEMENTS(search_strings)-1 DO BEGIN
  
    string_indx=WHERE(STRPOS(dummy[*], search_strings[i]) NE -1)
    
    IF string_indx EQ -1 THEN data[i]=!VALUES.F_NAN ELSE BEGIN
    
      data[i]=STRMID(dummy[string_indx], 30, 15)
  
    ENDELSE
  
  ENDFOR
  
  RETURN, data
END



PRO Sonde_quality_control

files=FILE_SEARCH('C:\Users\Wes Cantrell\Dropbox\Sonde Data\Huntsville\Database_rebuild\HU???\DATA\','*.de1', count=nfiles)

data=STRARR(nfiles, 17)

FOR j=0, nfiles-1 DO BEGIN

  data[j,*]=read_de1(files[j])

ENDFOR

date=data[*,1]
time=data[*,2]
fr_corr=FLOAT(data[*,14])

month=STRMID(date, 3, 2)
day=STRMID(date, 0, 2)
year=STRMID(date, 6, 4)

SET_PLOT, 'PS'

DEVICE, filename='C:\Users\Wes Cantrell\Dropbox\Ozonesonde Station\Flowrate_correction\flowrate_correction_analysis.ps'  $
                  , /color;, xoffset=.5,yoffset=.5,xsize=7.5,ysize=10 $
                  ;,/inches,/landscape
;!p.charsize=1.2 & !p.thick=2.0 & !x.thick=2.0 & !y.thick=2.0 
;!p.charthick=2.0 & !p.multi=[0,1,1]

;define color table
color_table_ps

;Flowrate correction Histogram
Histoplot, fr_corr $
         , xtitle='Flowrate Correction (%)'  $
         ;, xrange=[0,100] $
         , yrange=[0,0.2] $
         , /FREQUENCY $
         , binsize=0.1 




DEVICE, /CLOSE

stop
END