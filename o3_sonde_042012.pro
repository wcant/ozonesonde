;Purpose : Make plots with XXXFLT.DAT file
;Shi Kuang, UAH, 1/22/2005
;modified the error caused by bad RH value, 4/21/07

;update by Wesley Cantrell 7/2009
;-Added the potential temperature plot
; 8/22/09 Fixed data arrays to accommodate the new data column from STRATO vers. 9.12

;update by Wesley Cantrell 10/30/2010
;added 0-500m plot
;fixed ytitle



;set_plot,'ps'
inf=DIALOG_PICKFILE(/READ,TITLE='Select Sonde File to Read',FILTER = ['*FLT.DAT']) ;input file
;inf='D:\kuang\Sonde\hu301\hu301flt.dat'
ouf1=inf+'1.png'          ;whole plot
ouf2=inf+'2.png'          ;tropospheric plot
ouf3=inf+'3.png'          ;Potential Temperature Plot   -Wesley Cantrell 7/30/2009
ouf4=inf+'4.png'          ;0-500km mixing ratio         -Wesley Cantrell 10/30/2010
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
max_count=FILE_LINES(inf)-N_eLEMENTS(head)-1
while count NE max_count do begin
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



;REMOVE BAD RH VALUES
bv_index=WHERE(data[6,*] EQ 999999 OR data[6,*] EQ 99999)
IF bv_index[0] NE -1 THEN BEGIN
  data[6,bv_index]=!values.f_nan
ENDIF


;
;--------------------
;Plot partial P, T, RH
window,0,xsize=900,ysize=1150,title='Huntsville Ozonesonde Data'

;O3 partial pressure
plot,data(9,*),data(3,*),$
     xtitle='!6O3 Partial Pressure(mPa)',ytitle='Altitude(km)',$
     yticklen=0.5,ygridstyle=1,$
     xrange=[0,20],yrange=[0.2,40],xstyle=8,ystyle=1,$
     position=[0.08,0.2,0.48,0.8]
xyouts,0.5,0.12,subt2,/normal,ALIGNMENT=0.5
xyouts,0.5,0.10,fltnum,/normal,ALIGNMENT=0.5
xyouts,0.5,0.08,'Surface T='+STRCOMPRESS(STRING(data(4,0),FORMAT='(f4.1)'))+'(!UO!NC)'+$
       '; Surface O3='+STRCOMPRESS(STRING(data(10,0)*1000.,FORMAT='(f4.1)'))+'(ppbv)',/normal,ALIGNMENT=0.5
xyouts,15.2,37.3,'O3'
xyouts,15.2,35.8,'T',color=40
xyouts,15.2,34.3,'RH',color=10
plots,[17, 19],[37.5,37.5],linestyle=0
plots,[17, 19],[36,36],linestyle=3,color=40
plots,[17, 19],[34.5,34.5],linestyle=1,color=10
;temperature
axis,0,40,xaxis=1,XRANGE=(!x.CRANGE*6-80),xstyle=1,xtitle='Temperature(!UO!NC)'
oplot,(data(4,*)+80.)/6.,data(3,*),linestyle=3,color=40
;humdity,remove missing value--9999
alt=data(3,*)
RH=data(6,*)
index_RH=where (RH ne 9999, count_RH)
axis,0,44,xaxis=1,XRANGE =!x.CRANGE*5,xstyle=1,xtitle='Relative Humidity(%)'
if (count_RH ge 1) then begin
  oplot,RH(index_RH)/5.,alt(index_RH),linestyle=1,color=10
endif
;-----------------------------
;Plot mixing ratio
plot,data(10,*)*1000,data(3,*),clip=[0,0,200,15],$
     xtitle='O3 Mixing Ratio(ppbv)',$
     yticklen=0.5,ygridstyle=1,$
     xrange=[0,200],yrange=[0.2,40],xstyle=8,ystyle=1,$
     position=[0.52,0.2,0.92,0.8]
axis,0,40,xaxis=1,XRANGE = (!x.CRANGE/10),xstyle=1,xtitle='(ppmv)'
oplot,data(10,*)*10,data(3,*),linestyle=1,clip=[0,15,200,40]
xyouts,0.5,0.92,'Huntsville Ozonesonde Data',charsize=3.,/normal,ALIGNMENT=0.5
write_png,ouf1,tvrd(),red,green,blue

;-----------------------------
window,1,xsize=900,ysize=1150,xpos=0,ypos=0,title='Tropospheric Profile'
;Plot tropospheric profile
plot,data(9,*),data(3,*),$
     xtitle='O3 Partial Pressure(mPa)',ytitle='Altitude(km)',$
     yticklen=0.5,ygridstyle=1,$
     xrange=[0,10],yrange=[0.2,18],xstyle=8,ystyle=1,$
     position=[0.1,0.2,0.9,0.8]
xyouts,0.5,0.12,subt2,/normal,ALIGNMENT=0.5
xyouts,0.5,0.10,fltnum,/normal,ALIGNMENT=0.5
xyouts,0.5,0.08,'Surface T='+STRCOMPRESS(STRING(data(4,0),FORMAT='(f4.1)'))+'(!UO!NC)'+$
       '; Surface O3='+STRCOMPRESS(STRING(data(10,0)*1000.,FORMAT='(f4.1)'))+'(ppbv)',/normal,ALIGNMENT=0.5
xyouts,7.5,14,'O3'
xyouts,7.5,13.4,'T',color=40
xyouts,7.5,12.8,'RH',color=10
plots,[8, 8.8],[14.1,14.1],linestyle=0
plots,[8, 8.8],[13.5,13.5],linestyle=3,color=40
plots,[8, 8.8],[12.9,12.9],linestyle=1,color=10
xyouts,0.5,0.92,'Huntsville Ozonesonde Data',charsize=3.,/normal,ALIGNMENT=0.5
;temperature
axis,0,18,xaxis=1,XRANGE = (!x.CRANGE*12-80),xstyle=1,xtitle='Temperature(!UO!NC)'
oplot,(data(4,*)+80.)/12.,data(3,*),linestyle=3,color=40
;humdity
axis,0,19.8,xaxis=1,XRANGE =!x.CRANGE*10,xstyle=1,xtitle='Relative Humidity(%)'
if(count_RH ge 1) then begin
  oplot,RH(index_RH)/10.,alt(index_RH),linestyle=1,color=10
endif
write_png,ouf2,tvrd(),red,green,blue
;----------------------------------------------------
;--------------------
;Plot partial P, T, PT, RH

window,2,xsize=900,ysize=1150,xpos=0,ypos=0,title='Potential Temperature'

fltnum=STRCOMPRESS(head(4))
date=STRCOMPRESS(head(5))
time=STRCOMPRESS(head(6))
subt2=date+', '+time
;O3 partial pressure
plot,data(9,*),data(3,*),$
     xtitle='!6O3 Partial Pressure(mPa)',ytitle='Altitude(km)',$
     yticklen=0.5,ygridstyle=1,$
     xrange=[0,20],yrange=[0.2,20],xstyle=8,ystyle=1,$
     position=[0.08,0.2,0.48,0.8]
xyouts,0.5,0.12,subt2,/normal,ALIGNMENT=0.5
xyouts,0.5,0.10,fltnum,/normal,ALIGNMENT=0.5
xyouts,0.5,0.08,'Surface T='+STRCOMPRESS(STRING(data(4,0),FORMAT='(f4.1)'))+'(!UO!NC)'+$
       '; Surface O3='+STRCOMPRESS(STRING(data(10,0)*1000.,FORMAT='(f4.1)'))+'(ppbv)',/normal,ALIGNMENT=0.5
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
oplot,(data(5,*)-250.)/7.5,data(3,*),linestyle=3,color=5

;temperature
axis,0,21.4,xaxis=1,XRANGE=(!x.CRANGE*6-80),xstyle=1,xtitle='Temperature(!UO!NC)'
oplot,(data(4,*)+80.)/6.,data(3,*),linestyle=3,color=40
;humdity,remove missing value--9999
alt=data(3,*)
RH=data(6,*)
index_RH=where(RH ne 9999, count_RH)
axis,0,22.7,xaxis=1,XRANGE =!x.CRANGE*5,xstyle=1,xtitle='Relative Humidity(%)'
if (count_RH ge 1) then begin
  oplot,RH(index_RH)/5.,alt(index_RH),linestyle=1,color=10
endif
;-----------------------------
;Plot mixing ratio

plot,data(10,*)*1000,data(3,*),clip=[0,0,200,20],$
     xtitle='O3 Mixing Ratio(ppbv)',$
     yticklen=0.5,ygridstyle=1,$
     xrange=[0,200],yrange=[0.,20],xstyle=8,ystyle=1,$
     position=[0.52,0.2,0.92,0.8], /NOERASE
axis,0,20,xaxis=1,XRANGE = (!x.CRANGE/10),xstyle=1,xtitle='(ppmv)'
oplot,data(10,*)*10,data(3,*),linestyle=1,clip=[0,15,200,20]
xyouts,0.5,0.92,'Huntsville Ozonesonde Data',charsize=3.,/normal,ALIGNMENT=0.5
write_png,ouf3,tvrd(),red,green,blue
;-----------------------------
;
;
;
;------------------------------------------
;plot 0-500 km mixing ratio ( plot 4 )

window, 3, xsize=800, ysize=1150
indx=MAX(WHERE(data(3,*) LE 0.5))
plot, data(10,0:indx)*1000, data(3,0:indx), yrange=[0.196, 0.5]  $
      , xrange=[0,200], ytitle='Altitude (km)', xtitle='O3 Mixing Ratio(ppbv)', title='Huntsville Ozonesonde Data'
xyouts,0.5,0.44,subt2,/normal,ALIGNMENT=0.5
xyouts,0.5,0.42,fltnum,/normal,ALIGNMENT=0.5
xyouts,0.5,0.4,'Surface T='+STRCOMPRESS(STRING(data(4,0),FORMAT='(f4.1)'))+'(!UO!NC)'+$
       '; Surface O3='+STRCOMPRESS(STRING(data(10,0)*1000.,FORMAT='(f4.1)'))+'(ppbv)',/normal,ALIGNMENT=0.5
plot, data[0,0:indx], data(3, 0:indx), ytitle='Altitude (km)', xtitle='Time (min)', yrange=[0.196, 0.5]
write_png, ouf4, tvrd(), red, green, blue


;------------------------------------------

;plot from force launch time to balloon release (plot 5)
;release_time=3.+16./60.
;indx=MAX(WHERE(data[0,*] LE release_time));;

;window,4, xsize=800, ysize=1150
;plot, data(0,0:indx), data(10,0:indx)*1000, yrange=[0,100], xtitle='Time(min)', ytitle='ppbv', title='Force launch to Balloon Release'

;write_png, ouf4, tvrd(), red, green, blue

;stop
;----------------------------------------------

;DEVICE,/CLOSE
Stop
End