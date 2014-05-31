;Purpose : Make plots with XXXFLT.DAT file
;Shi Kuang, UAH, 1/22/2005
;modified the error caused by bad RH value, 4/21/07

;update by Wesley Cantrell 7/2009
;-Added the potential temperature plot
; 8/22/09 Fixed data arrays to accommodate the new data column from STRATO vers. 9.12

;update by Wesley Cantrell 10/30/2010
;added 0-500m plot
;fixed ytitle

PRO color_table

red=intarr(256) & green=intarr(256) & blue=intarr(256)

loadct,33,NCOLORS=100
tvlct,r,g,b,/get
red(0:99)=r(0:99) & green(0:99)=g(0:99) & blue(0:99)=b(0:99)

loadct,0,NCOLORS=30
tvlct,r,g,b,/get
;red(100:119)=r(10:29) & green(100:119)=g(10:29) & blue(100:119)=b(10:29)
red(100:119)=r(8:27) & green(100:119)=g(8:27) & blue(100:119)=b(8:27)


red(255)=255 & green(255)=255 & blue(255)=255 ;set for plot
red(254)=0 & green(254)=0 & blue(254)=0 ;set for background
;red(0)=0 & green(0)=0 & blue(0)=0 ;black color for default
tvlct,red,green,blue

!P.COLOR=254
!P.BACKGROUND=255

END

;set_plot,'ps'
;inf=DIALOG_PICKFILE(/READ,TITLE='Select Sonde File to Read',FILTER = ['*FLT.DAT']) ;input file
inf='\\uahdata\atmchem\Brian_folder\Tethered balloon\TET03\TET03FLT.dat'
;inf='\\uahdata\atmchem\Brian_folder\Tethered balloon\TET02\TET02FLT.dat'
ouf1=inf+'1_1.png'          ;whole plot

;device,file=ouf,/color,/inches,/portrait,xoffset=0.5,yoffset=0.5,xsize=7.5, ysize=9.5,bold=2
;!p.thick=2.0 & !x.thick=1.0 & !y.thick=1.0 & !p.charsize=0.80 & !p.multi=[0,1,2]
!p.thick=3.0 & !x.thick=1.5 & !y.thick=1.5 & !p.charsize=1.5 & !p.multi=[0,1,2]
;------------------------------------
color_table
val_col=[0,10,15,20,25,30,35,40,45,50,55,60,65,70,75,80,85,90,95,100]
col= [11,17,23,30,37,44,51,57,63,69,75,81,87,93,99,101,105,109,114,119]


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



;REMOVE BAD RH VALUES
bv_index=WHERE(data[6,*] EQ 999999 OR data[6,*] EQ 99999)
IF bv_index[0] NE -1 THEN BEGIN
  data[6,bv_index]=!values.f_nan
ENDIF



window,1,xsize=1200,ysize=800,xpos=0,ypos=0
;!p.font=0
!p.thick=2
;device,decomposed=0,retain=2
;loadct,13,bottom=0,ncolors=255
;!p.background=255
;!p.color=0

;a=data[0,0]
;b=data[3,0]*1000.0
;c=data[10,0]*1000.0

;cc=0

;for i=0,23-2 do begin

;if c ge val_col[i] and c lt val_col[i+1] then cc=col[i]  

;endfor

plot,data[0,*],data[3,*],/nodata,yrange=[0,400],color=fsc_color('black'),pos=[0.1,0.25,0.9,0.9],xminor=1,$
      xtickinterval=30,xtitle='Min. after launch',title='10/06,launch time: 0612',yminor=1,ytickinterval=100, $
      ytickname=[' ', ' ', '0','100','200']
      
      

for i=0,nn-1 do begin
  
a=data[0,i]
b=data[3,i]*1000.0
c=data[10,i]*1000.0
cc=0

for n=0,20-2 do begin

if c ge val_col[n] and c lt val_col[n+1] then cc=col[n]  

endfor

oplot,[a],[b],psym=1,color=cc

endfor

dcbar,col,label=val_col,position=[0.1,0.1,0.9,0.15];,color=fsc_color('black')

oplot,data(0,*),data(4,*)*4.0,color=fsc_color('red');temp
oplot,data(0,*),data(6,*)*4.0,color=fsc_color('black')
;oplot,[0,210],[0,0]

xyouts,-10,275,'Alt. (m)', orientation=90
;xyouts,-10,50, 'Temp. (C)', orientation=90
;xyouts,-10,-120,'RH',orientation=90


axis,yrange=[0,100],yaxis=1,ytitle='RH/Temp.(C)'

arrow,120,175,120,200,color=fsc_color('black'),/data,thick=2
xyouts,122,160,'RH'

arrow,150,110,150,75,color=fsc_color('black'),/data,thick=2
xyouts,152,110,'Temp'
;axis,-200,0,yrange=[0,100]

;xyouts,225,170,'Temp. (C)',color=fsc_color('red'),orientation=90

xyouts,0.5,-50,'ppmv'
;xyouts,


;!p.multi=[0,1,2,0,1]
;plot, data(0,*),data(10,*)*1000, xtitle='Min after launch', ytitle='ozone mixing ratio (ppb)',yrange=[0,100],xrange=[-30,210], $
;      xtickinterval=30,pos=[0.1,0.5,0.9,0.95],xtickname=[' ','0','30','60','90','120','150','180','210'],$
;      title='10/05/2011 Launch time: 06:23 Sunrise time: 06:44'
;xyouts,180,95,'ozone'
;xyouts,180,90,'Temp.',color=fsc_color('red')
;xyouts,180,85,'RH', color=fsc_color('green')
;axis, -20,0,yrange=[0,50],yaxis=0,ytitle='Temp. (C)'
;axis, yrange=[0,100],yaxis=1,ytitle='RH/Temp.(C)',ytickinterval=10,yminor=1
;axis, 0,-20,xtitle='Local Time',xtickinterval=10, xtickname=[' ','06',' ',' ',' ',' ','07',' ',' ',' ',' ','08',' ',' ',' ',' ','09',' ',' ',' ',' ','10',' ',' ',' ',' '],xminor=1

;oplot,data(0,*),data(4,*),color=fsc_color('red');temp
;oplot,data(0,*),data(6,*),color=fsc_color('green')



;plot,data(0,*),data(3,*)*1000.0,pos=[0.1,0.1,0.9,0.4],xrange=[-30,210],xtickinterval=30,ytickinterval=20,$
;     ytitle='Elevation (m)',yrange=[180,350]






write_png,ouf1,tvrd(/true)

stop


print, 'Tempretature:',mean(data(4,*)),stddev(data(4,*))
print, 'Theta:',mean(data(5,*)),stddev(data(5,*))
print, 'RH:', mean(data(6,*)),stddev(data(6,*))
print, 'O3 MR:',mean(data(10,*)*1000.0),stddev(data(10,*)*1000.0)



;p=plot3d(data(0,*),data(10,*),data(3,*))





















;DEVICE,/CLOSE
Stop
End