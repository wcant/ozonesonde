;Last updated 10/25/2012



PRO read_v7_csv, file, jday, year, month, day, hour, minute, second, temp, hum, ptemp, o3press_imet, o3mr_imet  $
               , gps_alt, alt, lat, lon, ascent_rate, fltnum


header=STRARR(25)
OPENR, lun, file, /GET_LUN
READF, lun, header

fltnum=STRMID(header[3], 22,5)

line=' '

col_headers=STRSPLIT(header[19], ',', /EXTRACT)

nlines=FILE_LINES(file)-25
jday=DBLARR(nlines)

temp=FLTARR(nlines)
hum=temp
ptemp=temp
o3press_imet=temp
o3mr_imet=temp
gps_alt=temp
alt=temp
lat=temp
lon=temp
ascent_rate=temp
day=STRARR(nlines)
month=day
year=day
hour=day
minute=day
second=day
date=day
time=day

k=0
WHILE NOT EOF(lun) DO BEGIN

  READF, lun, line
  line_split=STRSPLIT(line, ',', /EXTRACT)
  
  date[k]=STRTRIM(line_split[0],2)
  time[k]=STRTRIM(line_split[1],2)
  
  day[k]=FIX(STRMID(date[k], 8,2))
  month[k]=FIX(STRMID(date[k],5,2))
  year[k]=FIX(STRMID(date[k],0,4))
  hour[k]=FIX(STRMID(time[k],0,2))
  minute[k]=FIX(STRMID(time[k],3,2))
  second[k]=FIX(STRMID(time[k],6,2))

  jday[k]=JULDAY(month[k], day[k], year[k], hour[k], minute[k], second[k])

  temp[k]=FLOAT(line_split[7])
  hum[k]=FLOAT(line_split[9])
  ptemp[k]=FLOAT(line_split[13])
  o3press_imet[k]=FLOAT(line_split[20])
  o3mr_imet[k]=FLOAT(line_split[23])
  gps_alt[k]=FLOAT(line_split[33])
  alt[k]=FLOAT(line_split[5])
  lon[k]=FLOAT(line_split[32])
  lat[k]=FLOAT(line_split[31])
  ascent_rate[k]=FLOAT(line_split[16])
  

k++
ENDWHILE


max_alt=MAX(WHERE(gps_alt EQ MAX(gps_alt)))
temp=temp[0:max_alt]
hum=hum[0:max_alt]
ptemp=ptemp[0:max_alt]
o3press_imet=o3press_imet[0:max_alt]
o3mr_imet=o3mr_imet[0:max_alt]
gps_alt=gps_alt[0:max_alt]
alt=alt[0:max_alt]
lon=lon[0:max_alt]
ascent_rate=ascent_rate[0:max_alt]
fltnum=STRMID(header[3],21,6)

alt=gps_alt

END

PRO o3_sonde_V7

file=DIALOG_PICKFILE(/READ,TITLE='Select Sonde File to Read',FILTER = ['*.dat'])

;read_v7_csv, file, jday, year, month, day, hour, minute, second, temp, hum, ptemp, o3press_imet, o3mr_imet  $
;           , gps_alt, alt, lat, lon, ascent_rate, fltnum

;------------------------------------
inf=file
openr,1,file
nbig=15000
head=strarr(19)
tp=''  ;temporary string for header
data0=fltarr(21,nbig)
var1=fltarr(21) ;temporary variable

;read header
for i=0,18 do begin
  readf,1,tp
  head(i)=tp
  ;print,head(i)
endfor

;read sonde data
count=0
max_count=FILE_LINES(inf)-N_eLEMENTS(head)-1
while count NE max_count do begin
   readf,1,var1
   data0(*,count)=var1(*)
   count=count+1
endwhile

close,1
neof=count+1
print,'# of row=',neof
data1=fltarr(21,neof)
data1(*,*)=data0(*,0:neof-1)
;-------------------
;determine where is peak
alt=fltarr(neof)
alt(*)=data1(18,*)
altmax=max(alt)
index_max=where(alt eq altmax)
nn=index_max(0)+1
data=fltarr(21,nn)
data(*,*)=data0(*,0:nn-1)
;--------------------
fltnum=STRCOMPRESS(head(4))
date=STRCOMPRESS(head(5))
time=STRCOMPRESS(head(6))
subt2=date+', '+time

;!p.multi=[0,1,1]
;cd, 'C:\Documents and Settings\Admin\Desktop\HU646'
;plot, data[10,0:77]*1000, data[3,0:77], xtitle='O3 Mixing Ratio', ytitle='Altitude (km)', title='HU646'
;write_png, 'HU646-500m_mixingratio.png',tvrd(),red,green,blue



;REMOVE BAD RH VALUES
bv_index=WHERE(data[6,*] EQ 999999 OR data[6,*] EQ 99999)
IF bv_index[0] NE -1 THEN BEGIN
  data[6,bv_index]=!values.f_nan
ENDIF


fltnum_cut= strmid(strtrim(fltnum,2),2,5, /reverse_offset)

file_dir=STRMID(file,0,STRPOS(file,'\',/REVERSE_SEARCH))+'\'

ouf1=file_dir+'HU'+fltnum_cut+'FLT1.png'          ;whole plot
ouf2=file_dir+'HU'+fltnum_cut+'FLT2.png'          ;tropospheric plot
ouf3=file_dir+'HU'+fltnum_cut+'FLT3.png'          ;Potential Temperature Plot   -Wesley Cantrell 7/30/2009
ouf4=file_dir+'HU'+fltnum_cut+'FLT4.png'          ;0-500km mixing ratio         -Wesley Cantrell 10/30/2010
;device,file=ouf,/color,/inches,/portrait,xoffset=0.5,yoffset=0.5,xsize=7.5, ysize=9.5,bold=2
;!p.thick=2.0 & !x.thick=1.0 & !y.thick=1.0 & !p.charsize=0.80 & !p.multi=[0,1,2]
!p.thick=3.0 & !x.thick=1.5 & !y.thick=1.5 & !p.charsize=1.5 & !p.multi=[0,1,2]
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

;launch_index=MIN(WHERE(ascent_rate[25:N_ELEMENTS(ascent_rate)-1] GE 1.5))

;date=STRTRIM(STRING(month[0]),2)+'/'+STRTRIM(STRING(day[0]),2)+'/'+STRTRIM(STRING(year[0]),2)
;time=STRTRIM(STRING(hour[launch_index]),2)+':'+STRTRIM(STRING(minute[launch_index]),2)+':'+STRTRIM(STRING(second[launch_index]),2)


;------------------------------------
subt2=STRING(date)+', '+STRING(time)
;--------------------

;Plot partial P, T, RH
window,0,xsize=900,ysize=1150,title='Huntsville Ozonesonde Data'

;O3 partial pressure
plot,data[10,*],alt,$
     xtitle='!6O3 Partial Pressure(mPa)',ytitle='Altitude(km)',$
     yticklen=0.5,ygridstyle=1,$
     xrange=[0,20],yrange=[0.2,40],xstyle=8,ystyle=1,$
     position=[0.08,0.2,0.48,0.8]
xyouts,0.5,0.12,subt2,/normal,ALIGNMENT=0.5
xyouts,0.5,0.10,fltnum,/normal,ALIGNMENT=0.5
xyouts,0.5,0.08,'Surface T='+STRCOMPRESS(STRING(data[3,0],FORMAT='(f4.1)'))+'(!UO!NC)'+$
       '; Surface O3='+STRCOMPRESS(STRING(data[11,0]*1000.,FORMAT='(f4.1)'))+'(ppbv)',/normal,ALIGNMENT=0.5
xyouts,15.2,37.3,'O3'
xyouts,15.2,35.8,'T',color=40
xyouts,15.2,34.3,'RH',color=10
plots,[17, 19],[37.5,37.5],linestyle=0
plots,[17, 19],[36,36],linestyle=3,color=40
plots,[17, 19],[34.5,34.5],linestyle=1,color=10
;temperature
axis,0,40,xaxis=1,XRANGE=(!x.CRANGE*6-80),xstyle=1,xtitle='Temperature(!UO!NC)'
oplot,(data[3,*]+80.)/6.,alt,linestyle=3,color=40
;humdity,remove missing value--9999
axis,0,44,xaxis=1,XRANGE =!x.CRANGE*5,xstyle=1,xtitle='Relative Humidity(%)'
  oplot,data[6,*]/5.,alt,linestyle=1,color=10

;-----------------------------
;Plot mixing ratio
plot,data[11,*]*1000,alt,clip=[0,0,200,15],$
     xtitle='O3 Mixing Ratio(ppbv)',$
     yticklen=0.5,ygridstyle=1,$
     xrange=[0,200],yrange=[0.2,40],xstyle=8,ystyle=1,$
     position=[0.52,0.2,0.92,0.8]
axis,0,40,xaxis=1,XRANGE = (!x.CRANGE/10),xstyle=1,xtitle='(ppmv)'
oplot,data[11,*]*10,alt,linestyle=1,clip=[0,15,200,40]
xyouts,0.5,0.92,'Huntsville Ozonesonde Data',charsize=3.,/normal,ALIGNMENT=0.5
write_png,ouf1,tvrd(),red,green,blue

;-----------------------------
window,1,xsize=900,ysize=1150,xpos=0,ypos=0,title='Tropospheric Profile'
;Plot tropospheric profile
plot,data[10,*],alt,$
     xtitle='O3 Partial Pressure(mPa)',ytitle='Altitude(km)',$
     yticklen=0.5,ygridstyle=1,$
     xrange=[0,10],yrange=[0.2,18],xstyle=8,ystyle=1,$
     position=[0.1,0.2,0.9,0.8]
xyouts,0.5,0.12,subt2,/normal,ALIGNMENT=0.5
xyouts,0.5,0.10,fltnum,/normal,ALIGNMENT=0.5
xyouts,0.5,0.08,'Surface T='+STRCOMPRESS(STRING(data[3,0],FORMAT='(f4.1)'))+'(!UO!NC)'+$
       '; Surface O3='+STRCOMPRESS(STRING(data[11,0]*1000.,FORMAT='(f4.1)'))+'(ppbv)',/normal,ALIGNMENT=0.5
xyouts,7.5,14,'O3'
xyouts,7.5,13.4,'T',color=40
xyouts,7.5,12.8,'RH',color=10
plots,[8, 8.8],[14.1,14.1],linestyle=0
plots,[8, 8.8],[13.5,13.5],linestyle=3,color=40
plots,[8, 8.8],[12.9,12.9],linestyle=1,color=10
xyouts,0.5,0.92,'Huntsville Ozonesonde Data',charsize=3.,/normal,ALIGNMENT=0.5
;temperature
axis,0,18,xaxis=1,XRANGE = (!x.CRANGE*12-80),xstyle=1,xtitle='Temperature(!UO!NC)'
oplot,(data[3,*]+80.)/12.,alt,linestyle=3,color=40
;humdity
axis,0,19.8,xaxis=1,XRANGE =!x.CRANGE*10,xstyle=1,xtitle='Relative Humidity(%)'
  oplot,data[6,*]/10.,alt,linestyle=1,color=10

write_png,ouf2,tvrd(),red,green,blue
;----------------------------------------------------
;--------------------
;Plot partial P, T, PT, RH

window,2,xsize=900,ysize=1150,xpos=0,ypos=0,title='Potential Temperature'

subt2=date+', '+time
;O3 partial pressure
plot,data[10,*],alt,$
     xtitle='!6O3 Partial Pressure(mPa)',ytitle='Altitude(km)',$
     yticklen=0.5,ygridstyle=1,$
     xrange=[0,20],yrange=[0.2,20],xstyle=8,ystyle=1,$
     position=[0.08,0.2,0.48,0.8]
xyouts,0.5,0.12,subt2,/normal,ALIGNMENT=0.5
xyouts,0.5,0.10,fltnum,/normal,ALIGNMENT=0.5
xyouts,0.5,0.08,'Surface T='+STRCOMPRESS(STRING(data[3,0],FORMAT='(f4.1)'))+'(!UO!NC)'+$
       '; Surface O3='+STRCOMPRESS(STRING(data[11,0]*1000.,FORMAT='(f4.1)'))+'(ppbv)',/normal,ALIGNMENT=0.5
xyouts,15.2,19.0,'O3'
xyouts,15.2,18.5,'PT',color=5
xyouts,15.2,18.0,'T',color=40
xyouts,15.2,17.5,'RH',color=10
plots,[17, 19],[19.0,19.0],linestyle=0
plots,[17, 19],[18.5,18.5],linestyle=3,color=5
plots,[17, 19],[18.0,18.0],linestyle=3,color=40
plots,[17, 19],[17.5,17.5],linestyle=1,color=10
;potential temperature
axis,0,20,xaxis=1,XRANGE=[250,400],xstyle=1,xtitle='Potential Temperature(K)'
oplot,(data[5,*]-250.)/7.5,alt,linestyle=3,color=5

;temperature
axis,0,21.4,xaxis=1,XRANGE=(!x.CRANGE*6-80),xstyle=1,xtitle='Temperature(!UO!NC)'
oplot,(data[3,*]+80.)/6.,alt,linestyle=3,color=40

;humidity
axis,0,22.7,xaxis=1,XRANGE =!x.CRANGE*5,xstyle=1,xtitle='Relative Humidity(%)'
oplot,data[6,*]/5.,alt,linestyle=1,color=10

;-----------------------------
;Plot mixing ratio

plot,data[11,*]*1000,alt,clip=[0,0,200,20],$
     xtitle='O3 Mixing Ratio(ppbv)',$
     yticklen=0.5,ygridstyle=1,$
     xrange=[0,200],yrange=[0.,20],xstyle=8,ystyle=1,$
     position=[0.52,0.2,0.92,0.8], /NOERASE
axis,0,20,xaxis=1,XRANGE = (!x.CRANGE/10),xstyle=1,xtitle='(ppmv)'
oplot,data[11,*]*10,alt,linestyle=1,clip=[0,15,200,20]
xyouts,0.5,0.92,'Huntsville Ozonesonde Data',charsize=3.,/normal,ALIGNMENT=0.5
write_png,ouf3,tvrd(),red,green,blue
;-----------------------------
;
;
;
;------------------------------------------
;plot 0-500m mixing ratio ( plot 4 )

window, 3, xsize=800, ysize=1150

plot, data[11,*]*1000, alt, yrange=[0.196, 0.5]  $
      , xrange=[0,200], ytitle='Altitude (km)', xtitle='O3 Mixing Ratio(ppbv)', title='Huntsville Ozonesonde Data'
xyouts,0.5,0.44,subt2,/normal,ALIGNMENT=0.5
xyouts,0.5,0.42,fltnum,/normal,ALIGNMENT=0.5
xyouts,0.5,0.4,'Surface T='+STRCOMPRESS(STRING(data[3,0],FORMAT='(f4.1)'))+'(!UO!NC)'+$
       '; Surface O3='+STRCOMPRESS(STRING(data[11,0]*1000.,FORMAT='(f4.1)'))+'(ppbv)',/normal,ALIGNMENT=0.5
;plot, data[0,0:indx], alt, ytitle='Altitude (km)', xtitle='Time (min)', yrange=[0.196, 0.5]
write_png, ouf4, tvrd(), red, green, blue


;------------------------------------------


stop
END