;Data analysis for walk around campus on 1/18/2011



inf=DIALOG_PICKFILE(/READ,TITLE='Select Sonde File to Read',FILTER = ['*FLT.DAT']) ;input file
;inf='D:\kuang\Sonde\hu301\hu301flt.dat'
ouf1=inf+'1.png'          ;whole plot
ouf2=inf+'2.png'          ;tropospheric plot
ouf3=inf+'3.png'          ;Potential Temperature Plot   -Wesley Cantrell 7/30/2009
ouf4=inf+'4.png'          ;0-500km mixing ratio         -Wesley Cantrell 10/30/2010
ouf5=inf+'5.png'          ;plot o3 from force launch to balloon release -Wesley Cantrell 12/4/2010
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

;------------------------------------
openr,1,inf
nbig=15000
head=strarr(19)
tp=''  ;temporary string for header
data0=fltarr(14,nbig)
var1=fltarr(14) ;temporary variable

;read header
for i=0,18 do begin
  readf,1,tp
  head(i)=tp
  ;print,head(i)
endfor

;read sonde data
count=0
while not eof(1) do begin
   readf,1,var1
   data0(*,count)=var1(*)
   count=count+1
endwhile
close,1
neof=count+1
print,'# of row=',neof
data1=fltarr(14,neof)
data1(*,*)=data0(*,0:neof-1)
;-------------------
;determine where is peak
alt=fltarr(neof)
alt(*)=data1(3,*)
altmax=max(alt)
index_max=where(alt eq altmax)
nn=index_max(0)+1
data=fltarr(14,nn)
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

data[10,*]=data[10,*]*1000
time=data[0,*]

;1. based of ramp to highbay
time1=WHERE(time GE 0.5 and time LE 1.)
o3_1=MEAN(data[10,time1])

;2. top of concrete walls
time2=WHERE(time GE 1.6 and time LE 2.1)
o3_2=MEAN(data[10,time2])

;3. launch site
time3=WHERE(time GE 2.70 and time LE 3.23)
o3_3=MEAN(data[10,time3])

;4. fence near launch site
time4=WHERE(time GE 3.95 and time LE 4.5)
o3_4=MEAN(data[10,time4])

;5. NW corner of parking lot
time5=WHERE(time GE 7.66 and time LE 8.16)
o3_5=MEAN(data[10,time5])

;6. Sparkman and Bradford intersection
time6=WHERE(time GE 9.66 and time LE 12.66)
o3_6=MEAN(data[10,time6])

;7. Entrance to UAH between ponds
time7=WHERE(time GE 14.92 and time LE 15.42)
o3_7=MEAN(data[10,time7])

;8. Flags near shelby / engineering
time8=WHERE(time GE 17 and time LE 17.5)
o3_8=MEAN(data[10,time8])

;9. Front of shelby
time9=WHERE(time GE 19 and time LE 19.5)
o3_9=MEAN(data[10,time9])

;10. art by shelby ( ~SE corner)
time10=WHERE(time GE 20.5 and time LE 21.06)
o3_10=MEAN(data[10,time10])

;11. parking garage
time11=WHERE(time GE 23 and time LE 23.52)
o3_11=MEAN(data[10,time11])




window, 0, xsize=1150, ysize=800

plot, data[0,time1[0]:time11[WHERE(time11 EQ MAX(time11))]], data[10,time1[0]:time11[WHERE(time11 EQ MAX(time11))]], xrange=[0,23.52], xtitle='Minutes'  $
    , ytitle='ppbv'

;oplot, data[0,time1[0]:time11[WHERE(time11 EQ MAX(time11))]], (data[2,time1[0]:time11[WHERE(time11 EQ MAX(time11))]]*50.)/0.3

cd, 'C:\Documents and Settings\Admin\Desktop'
write_png, '1_18_2011_campus_sfc_o3.png', tvrd(), red, green, blue



stop
END