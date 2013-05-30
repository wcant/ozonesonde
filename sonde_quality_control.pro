FUNCTION read_de1, file

  OPENR, lun, file, /GET_LUN
  nlines=FILE_LINES(file)
  dummy=STRARR(nlines)
  READF, lun, dummy
  
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
    data[i]=STRMID(dummy[string_indx], 30, 15)
  
  ENDFOR
  
  RETURN, data
END




PRO Sonde_quality_control

file=FILE_SEARCH('C:\Users\Wes Cantrell\Dropbox\Sonde Data\Huntsville\Database_rebuild\HU786\DATA\','*.de1', count=nfiles)

data=read_de1(file)



stop
END