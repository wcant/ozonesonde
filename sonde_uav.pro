PRO sonde_uav

file='C:\Users\Wes Cantrell\Dropbox\Sites\GEplot\UAV\20130930_o3_flt4.txt'
sonde_template=ASCII_TEMPLATE(file)
data=READ_ASCII(file, count=count, data_start=19, delimiter=',', header=header)
;restore, 'C:\Users\Wes Cantrell\Dropbox\Sonde Data\Huntsville\UAV\ua006_20130930.sav'
time=data.field01[0,*]
o3mr=data.field01[11,*]*1000
alt=data.field01[2,*]*1000
o3current=data.field01[9,*]
lat=DOUBLE(data.field01[16,*])
lon=DOUBLE(data.field01[17,*])
gps_alt=data.field01[18,*]*1000

;remove tethered balloon data
o3mr[WHERE(time GE 50 AND time LE 125)]=!VALUES.F_NAN

;convert time to hours/minutes/seconds
;hours=
;minutes
;seconds

;write GEplot csv file
OPENW, lun, 'C:\Users\Wes Cantrell\Dropbox\Sites\GEplot\UAV\20130930_o3flt4.dat', /GET_LUN
FOR k=0, N_ELEMENTS(time)-1 DO PRINTF, lun, STRING(time[k])+','+STRING(lat[k])+','+STRING(ABS(lon[k]))+','+STRING(o3mr[k])+','+STRING(alt[k])
FREE_LUN, lun


stop
;Set plot device/file
PS_START, 'C:\Users\Wes Cantrell\Dropbox\Sonde Data\Huntsville\UAV\20130930_o3_no3_uav.ps'
!p.thick=3.0 & !x.thick=1.5 & !y.thick=1.5 & !p.charsize=1.5  

;Build color table
red=intarr(256) & green=intarr(256) & blue=intarr(256)
loadct,33,NCOLORS=10
tvlct,r,g,b,/get
red(0:9)=r(0:9) & green(0:9)=g(0:9) & blue(0:9)=b(0:9)
red(255)=255 & green(255)=255 & blue(255)=255 ;set for plot
red(254)=0 & green(254)=0 & blue(254)=0 ;set for background
;red(0)=0 & green(0)=0 & blue(0)=0 ;black color for default
tvlct,red,green,blue
!P.COLOR=254
!P.BACKGROUND=255

color_table
val_col=[0,5,10,15,20,25,30,35,40,45,50]
col= [11,23,37,51,63,75,87,99,105,114,119]

plot, time, gps_alt $
    , /NODATA $
    , yrange=[190,300]  $
    , color=fsc_color('black') $
    , pos=[0.1,0.1,0.8,0.9] $
    , xminor=1 $
    , xtickinterval=20  $
    , xtitle='Min. after power on'  $
    , title='2013/09/30'  $
    , yminor=1 $
    , ytickinterval=10 $
    , ytitle='Alt (m) ASL'
   ;, ytickname=[' ', ' ', '0','100','200']

for i=0,N_ELEMENTS(time)-1 do begin
  a=time[i]
  b=gps_alt[i]
  c=o3mr[i]
  cc=0
  for n=0,11-2 do begin
    if c ge val_col[n] and c lt val_col[n+1] then cc=col[n] 
  endfor
  IF FINITE(c) EQ 1 THEN oplot,[a],[b],psym=1,color=cc
endfor

cgCOLORBAR, /VERTICAL, /RIGHT $
          , ncolors=N_ELEMENTS(col) $
          , palette=[[r[col]],[g[col]],[b[col]]]  $
          , divisions=N_ELEMENTS(col) $
          , position=[0.85,0.1,0.9,0.9]

PS_END


stop
END