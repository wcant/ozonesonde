;Data analysis for walk around campus on 1/22/2011



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


;=================================================================================
;Pressure experiment
;sample_press=FLTARR(50)
;sample_time=INDGEN(50)

;std surface pressure
;sample_press[*]=990.0 

;outliers
;sample_press[10]=1000.   
;sample_press[20]=980.

;sample_alt=FLTARR(N_ELEMENTS(sample_press)-1)

;FOR i=1, N_ELEMENTS(sample_alt)-1 DO BEGIN

;  sample_alt[i-1]=alog(sample_press[i]/sample_press[i-1])

;ENDFOR



;plot, data[0, WHERE(data[0,*] GE 3. AND data[0,*] LE 4.)], data[2,WHERE(data[0,*] GE 3. AND data[0,*] LE 4.)], yrange=[980,1000], psym=4

;calc alt from measured pressure

;indxs=WHERE(data[0,*] GE 3. AND data[0,*] LE 4.)
;calc_alt=FLTARR(N_ELEMENTS(indxs)-1)

;FOR i=1, N_ELEMENTS(WHERE(data[0,*] GE 3. AND data[0,*] LE 4.))-1 DO BEGIN


 ; calc_alt[i-1]=-((287.058*(data[4,indxs[i-1]]+273))/(9.81))*alog(data[2,indxs[i]]/data[2,indxs[0]])

;ENDFOR

;plot, data[0,indxs], calc_alt, psym=4, xtitle='minutes', ytitle='Delta Z from origin'

;stop
;=================================================================================


;1. East NSSTC
time1=WHERE(time GE 1.43 and time LE 1.93)
o3_1=MEAN(data[10,time1])

;2. SE NSSTC
time2=WHERE(time GE 2.8 and time LE 3.30)
o3_2=MEAN(data[10,time2])

;3. UAH entrance intersection
time3=WHERE(time GE 4.13 and time LE 4.83)
o3_3=MEAN(data[10,time3])

;4. Btwn ponds
time4=WHERE(time GE 5.25 and time LE 5.75)
o3_4=MEAN(data[10,time4])

;5. flags
time5=WHERE(time GE 7.33 and time LE 7.83)
o3_5=MEAN(data[10,time5])

;6. madison hall
time6=WHERE(time GE 8.75 and time LE 9.33)
o3_6=MEAN(data[10,time6])

;7. engineering front
time7=WHERE(time GE 10.66 and time LE 11.5)
o3_7=MEAN(data[10,time7])

;8. NE eng
time8=WHERE(time GE 12.66 and time LE 13.16)
o3_8=MEAN(data[10,time8])

;9. Optics
time9=WHERE(time GE 15.58 and time LE 16.08)
o3_9=MEAN(data[10,time9])

;10. Btwn bank and charger village
time10=WHERE(time GE 17.83 and time LE 18.33)
o3_10=MEAN(data[10,time10])

;11. NE parking garage
time11=WHERE(time GE 20.5 and time LE 21.)
o3_11=MEAN(data[10,time11])

;12. inside chic fil a
time12=WHERE(time GE 21. and time LE 26.)
o3_12=MEAN(data[10,time12])

;13. NW parking
time13=WHERE(time GE 26.16 and time LE 26.66)
o3_13=MEAN(data[10,time13])

;14. rd btwn parking and shelby
time14=WHERE(time GE 27.5 and time LE 28.)
o3_14=MEAN(data[10,time14])

;15. SE shelby
time15=WHERE(time GE 29.16 and time LE 29.66)
o3_15=MEAN(data[10,time15])

;16. Lawn shelby
time16=WHERE(time GE 30.5 and time LE 31.33)
o3_16=MEAN(data[10,time16])

;17. Overpass shelby
time17=WHERE(time GE 32. and time LE 32.83)
o3_17=MEAN(data[10,time17])

;18. N of holmes grass
time18=WHERE(time GE 33.66 and time LE 34.25)
o3_18=MEAN(data[10,time18])

;19.  Spark brad int
time19=WHERE(time GE 35. and time LE 37.)
o3_19=MEAN(data[10,time19])

;20. NE parking nsstc
time20=WHERE(time GE 38.5 and time LE 39.)
o3_20=MEAN(data[10,time20])

;21. NW parking by trees
time21=WHERE(time GE 40.16 and time LE 40.66)
o3_21=MEAN(data[10,time21])



window, 0, xsize=1150, ysize=800

plot, data[0,WHERE(Data[3,*] LE 0.3)], data[10,WHERE(Data[3,*] LE 0.3)], xrange=[0,42], xtitle='Minutes'  $
    , ytitle='ppbv'

;oplot, data[0,time1[0]:time11[WHERE(time11 EQ MAX(time11))]], (data[2,time1[0]:time11[WHERE(time11 EQ MAX(time11))]]*50.)/0.3

cd, 'C:\Documents and Settings\Admin\Desktop\HU663'
write_png, '1_28_2011_ALLcampus_sfc_o3.png', tvrd(), red, green, blue



END