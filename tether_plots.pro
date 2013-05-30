Pro Decide_color, value, val_col, col, color_index

        if(value lt val_col(0)) then begin
            color_index=255
            goto, jump5
         endif
         for ic=1, n_elements(val_col)-1 do begin
             if(value lt val_col(ic)) then begin
                 color_index=col(ic-1)
                 goto, jump5
             endif
         endfor
         color_index=col(n_elements(col)-1)  ;max color
         jump5: aaa=1

End
PRO color_table_ps

red=intarr(256) & green=intarr(256) & blue=intarr(256)

loadct,33,NCOLORS=100
tvlct,r,g,b,/get
red(0:99)=r(0:99) & green(0:99)=g(0:99) & blue(0:99)=b(0:99)

loadct,0,NCOLORS=30
tvlct,r,g,b,/get
red(100:119)=r(10:29) & green(100:119)=g(10:29) & blue(100:119)=b(10:29)


red(255)=255 & green(255)=255 & blue(255)=255 ;set for plot
red(254)=0 & green(254)=0 & blue(254)=0 ;set for background
red(0)=0 & green(0)=0 & blue(0)=0 ;black color for default
tvlct,red,green,blue

!P.COLOR=254
!P.BACKGROUND=255

END


PRO Tether_plots

;file=DIALOG_PICKFILE(/READ,TITLE='Select Sonde File to Read',FILTER = ['*.CSV'])
file='C:\Users\Wes Cantrell\Dropbox\Sonde Data\Huntsville\Tether_flights\hu003_20120824\hu003_20120824.csv'
;file='C:\Users\Wes Cantrell\Dropbox\Sonde Data\Huntsville\Tether_flights\hu003_20120824\hu003_20120824.csv'
header=STRARR(25)
OPENR, lun, file, /GET_LUN
READF, lun, header

fltnum=STRMID(header[3], 22,5)

line=' '

col_headers=STRSPLIT(header[19], ',', /EXTRACT)

nlines=FILE_LINES(file)-25
jday=DBLARR(nlines)

temp=FLTARR(nlines) &temp[*]=!VALUES.F_NAN
hum=temp
ptemp=temp
o3press_imet=temp
o3mr_imet=temp
gps_alt=temp
alt=temp


k=0
WHILE NOT EOF(lun) DO BEGIN

  READF, lun, line
  line_split=STRSPLIT(line, ',', /EXTRACT)
  
  date=STRTRIM(line_split[0],2)
  time=STRTRIM(line_split[1],2)
  
  day=FIX(STRMID(date, 0,2))
  month=FIX(STRMID(date,3,2))
  year=FIX(STRMID(date,6,4))
  hour=FIX(STRMID(time,0,2))
  minute=FIX(STRMID(time,3,2))
  second=FIX(STRMID(time,6,2))
  
  jday[k]=JULDAY(month, day, year, hour, minute, second)

  temp[k]=FLOAT(line_split[7])
  hum[k]=FLOAT(line_split[9])
  ptemp[k]=FLOAT(line_split[13])
  o3press_imet[k]=FLOAT(line_split[20])
  o3mr_imet[k]=FLOAT(line_split[23])*1000
  gps_alt[k]=FLOAT(line_split[33])
  alt[k]=FLOAT(line_split[5])
  
k++
ENDWHILE

;set alt to AGL in meters
alt=(alt-0.212)*1000
gps_alt=(gps_alt-0.212)*1000

FREE_LUN, lun

SET_PLOT, 'PS'
DEVICE, filename='C:\Users\Wes Cantrell\Dropbox\Sonde Data\Huntsville\Tether_flights\hu003_20120824\Tether_'+fltnum+'.ps'  $
      , /color;, xoffset=.5,yoffset=.5,xsize=7.5,ysize=10,/inches,/landscape
!p.charsize=1.2 & !p.thick=2.0 & !x.thick=2.0 & !y.thick=2.0 
!p.charthick=2.0 & !p.multi=[0,1,1]
color_table_ps
date_label = LABEL_DATE(DATE_FORMAT = ['%H','%D %M'])

time_range=[MIN(jday), MAX(jday)]
alt_range=[MIN(gps_alt), MAX(gps_alt)]

val_col=[0, 20,25,30,35,40,45,50,55,60,65,70,75,80,85,90,95,100,125,150,200,300,600]
col=      [1, 5, 11,17,23,30,37,44,51,57,63,69,75,81,87,93,99,101,105,109,114,119]


;O3 mixing ratio plot
plot, time_range, alt_range $
    , xtitle='!6 GMT' $
    , ytitle='Alt AGL (m)'  $
   ; , title='!6 O3 Mixing Ratio (ppbv)' $
    , xstyle=3 $
    ;, ystyle=2 $
    , /NODATA  $
    , XTICKFORMAT = ['LABEL_DATE','LABEL_DATE'] $
    , XTICKUNITS = ['Hour','Day']  $
    , XTICKINTERVAL=1  $
    , yminor=1 $
    , xminor=1  $
    , yrange=[0,200]  $
    , clip=[time_range[0],0,time_range[1], 200] $
    , position=[-0.2, 0, .92, 1]

  FOR i=0, nlines-2 DO BEGIN
  
    Decide_color, o3mr_imet[i], val_col, col, color_index
;    polyfill,[jday[i], jday[i+1], jday[i+1], jday[i]], [gps_alt[i], gps_alt[i], gps_alt[i+1], gps_alt[i+1]] $
     oplot, [jday[i]], [gps_alt[i]] $
            , color=color_index $
            , psym=2  $
            , symsize=0.5
            ;, clip=[time_range[0],0,time_range[1], 200]
  ;print, color_index
  
  ENDFOR
  
val5_2=indgen(21)*5
col5=(indgen(20)+1)*5-1
vert_color_bar,1.02,0.2,1.05,0.8,val5_2,col5,form='(i4)',SIZE_OWN=0.8,THICK_OWN=2

xyouts,-10,275,'Alt. (m)', orientation=90

oplot,jday, temp*2.0,color=fsc_color('red');temp
oplot,jday, hum*2.0,color=fsc_color('black')

axis,yrange=[0,100],yaxis=1,ytitle='Temp.(C)/RH'

;arrow,0.82,0.87,0.87,0.92,color=fsc_color('black'),thick=2, /normal
xyouts,0.82,0.85,'RH', /normal

;arrow,0.82,0.82,0.87,0.87,color=fsc_color('red'),thick=2, /normal
xyouts,0.82,0.81,'Temp', /normal, color=fsc_color('red')



DEVICE, /CLOSE



stop
END