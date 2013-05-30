
file='C:\Dropbox\EPA Data\Jun2012-014.txt'

hourly_epa_reader_vers2, file, data, hours, days, month


set_plot, 'win'
!p.thick=1.0 & !x.thick=1.5 & !y.thick=1.5 & !p.charsize=1.5 
;------------------------------------
red=indgen(47)
green=indgen(47)
blue=indgen(47)
red(0:46)=  [255, 0,  0,0,0,0,0,7,15,23,31,38,46,54,62,86,110,134,158,182,206,$
              230,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,$
              255,255,255,255,255,255,255,255,255,255]

green(0:46)=[255, 0, 0,0,0,0,0,28,56,84,112,140,168,196,224,227,231,235,239,243,247,$
            251,255,249,243,237,232,226,220,214,209,182,156,130,104,78,52,$
            26,0,0,0,0,0,0,0,0,0]

blue(0:46)= [255, 0, 109,145,182,218,255,223,191,159,127,95,63,31,0,0,0,0,0,0,0,$
              0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,31,63,95,127,159,191,223,255]
              
tvlct,red,green,blue


plot, hours, data[0,*], xrange=[0,23], yrange=[0,100], xtitle='Hour (Local)'  $
    , ytitle='Mixing Ratio (ppbv)', title='EPA Ozone Hourly Averages, Airport Rd.', /NODATA
    
    FOR i=0, 30-1 DO BEGIN
    
      oplot, hours, data[i,*], psym=4
      oplot, hours, data[i,*]
    
    ENDFOR
    
    oplot, hours, data[29,*], color=40, thick=2
    oplot, hours, data[29,*], color=40, thick=2, psym=4
    
    oplot, hours, data[22,*], color=5, thick=2
    oplot, hours, data[22,*], color=5, thick=2, psym=4
    
    write_png, 'C:\Dropbox\EPA Data\June2012_hourly_ozone.png', tvrd(), red, green, blue

stop
END