Pro Smooth_O3,o3,alt,lw_lim,up_lim,points,o3s,alts
;Purpose : filtering & smoothing
;Input : o3   --o3 number density
;        alt  --altitude
;        points--points of smoothing, if be 0, do not smooth
;        lw_lim--lower limit
;        up_lim--upper limit
;Output : o3s --new o3 number density
;       : alts--new altitude
nn=N_elements(o3)
;lw_lim=1.e11 ;lower limit
;up_lim=5.e12 ;upper limit
t1=fltarr(nn)
t2=fltarr(nn)
nt=0
;print,' alt(m)  ,   O3 # density'
for i=0,nn-1 do begin
  ;alt less than 15000 --- troposphere
  if(o3(i) ge lw_lim and o3(i) le up_lim) then begin
    ;print,alt(i),o3(i)
    t1(nt)=alt(i)
    t2(nt)=o3(i)
    nt=nt+1
  endif
endfor
if i eq 125 then stop
if (nt gt points) then begin
  alts=fltarr(nt)
  o3s0=fltarr(nt)
  alts=t1(0:nt-1)
  o3s0=t2(0:nt-1)
  ;results = POLY_FIT(alts, o3s0, 4,SIGMA=sigma,MEASURE_ERRORS=measure_errors, YFIT=o3s)
  ;print,results
  ;print,'SIGMA= ',sigma
  ;print,'MEASURE_ERRORS= ',measure_errors
  if (points gt 1) then begin
     o3s=SMOOTH(o3s0,points,/EDGE_TRUNCATE) ;smoothing
  endif else begin
     o3s=o3s0
  endelse
endif else begin
  print, 'No smoothing because too few grids'
  alts=alt
  o3s=o3
endelse

IF N_ELEMENTS(WHERE(o3 NE -999)) LT 50 THEN BEGIN
  o3[0,*]=-999
  o3s=o3
ENDIF

End
;=====================================================================================
Pro Curtain_pixel,O3,xtime,altO3,height_range,val_col,col, flag, position  ;
;val_col:  value displayed on color bar,  dimension is one larger than "col"
;col: color on color bar
;levelind: only show these levels

levelind=val_col

;num_color=100
;max_O3=400. ;in unit of (ppbv)
;min_O3=0.

;val_col=indgen(num_color+1)*(max_O3-min_O3)/num_color+min_O3
;col=indgen(num_color)
;levelind=indgen(41)*10


;if((max(xtime)-min(xtime)) ge 0.5) then begin
   ;time_range=[min(xtime),max(xtime)]
   time_range=[floor(min(xtime)),floor(max(xtime))+1]
;endif else begin
;   time_range=[min(xtime),min(xtime)+0.5]
;endelse

nofiles=n_elements(xtime)
nO3=n_elements(altO3)/nofiles
plot, time_range,[0,35], /nodata,$
      xtitle='!6Date',ytitle='Alt (km)',title='!6',$
      ;XTICKFORMAT = ['LABEL_DATE', 'LABEL_DATE'], XTICKUNITS = ['Hour','Day'],XTICKINTERVAL=1,$
      position=position,$
      ;yrange=height_range,xstyle=3,ystyle=2
      yrange=[0,35],xstyle=3,ystyle=2

 for kt=1,nofiles-2 do begin
     alt2=altO3(kt,*) &  O32=O3(kt,*)
     isort=sort(alt2)
     alt2=alt2(isort) & O32=O32(isort)  ;sort alt

     for jalt=0,no3-2 do begin

         for ic=1, n_elements(val_col)-1 do begin
             if(O32(jalt) lt val_col(ic)) then begin
                 color_index=col(ic-1)
                 goto, jump5
             endif
         endfor
         color_index=col(n_elements(col)-1)  ;max color
         jump5: aaa=1


        if (alt2(jalt)/1000. le height_range(1) and alt2(jalt)/1000. ge height_range(0) and $
                     (alt2(jalt+1)/1000. le height_range(1)+1) and (alt2(jalt+1)/1000. ge height_range(0)) ) then begin
         ;xd=xtime(kt+1)-xtime(kt)
         yd=alt2(jalt+1)-alt2(jalt)
         x1=xtime(kt)-(xtime(kt)-xtime(kt-1))/2.
         x2=xtime(kt)+(xtime(kt+1)-xtime(kt))/2.
         box_x=1D0*[x1,x2,x2,x1]
         box_y=1D0*[alt2(jalt),alt2(jalt),alt2(jalt)+yd,alt2(jalt)+yd]/1000.
         polyfill,box_x,box_y,color=color_index
        endif
     endfor
 endfor

;plot last time line
xd=xtime(nofiles-1)-xtime(nofiles-2)
for jalt=0,no3-2 do begin
         ;last line
         for ic=1, n_elements(val_col)-1 do begin
             if(O3(nofiles-1,jalt) lt val_col(ic)) then begin
                 color_index=col(ic-1)
                 goto, jump6
             endif
         endfor
         color_index=col(n_elements(col)-1)  ;max color
         jump6: aaa=1

       if (altO3(nofiles-1,jalt)/1000. le height_range(1) and altO3(nofiles-1,jalt)/1000. ge height_range(0) and $
                   (altO3(nofiles-1,jalt+1)/1000. le height_range(1)+1) and (altO3(nofiles-1,jalt+1)/1000. ge height_range(0)) ) then begin
         yd=altO3(nofiles-1,jalt+1)-altO3(nofiles-1,jalt)
         box_x=1D0*[xtime(nofiles-1)-xd/2.,xtime(nofiles-1)+0.01,xtime(nofiles-1)+0.01,xtime(nofiles-1)-xd/2.]
         box_y=1D0*[altO3(nofiles-1,jalt),altO3(nofiles-1,jalt),altO3(nofiles-1,jalt)+yd,altO3(nofiles-1,jalt)+yd]/1000.
         polyfill,box_x,box_y,color=color_index
       endif
endfor

;first time line
xd=xtime(1)-xtime(0)
for jalt=0,no3-2 do begin
         ;last line
         for ic=1, n_elements(val_col)-1 do begin
             if(O3(0,jalt) lt val_col(ic)) then begin
                 color_index=col(ic-1)
                 goto, jump7
             endif
         endfor
         color_index=col(n_elements(col)-1)  ;max color
         jump7: aaa=1

       if (altO3(0,jalt)/1000. le height_range(1) and altO3(0,jalt)/1000. ge height_range(0) and $
                  (altO3(0,jalt+1)/1000. le height_range(1)+1) and (altO3(0,jalt+1)/1000. ge height_range(0)) ) then begin
         yd=altO3(0,jalt+1)-altO3(0,jalt)
         box_x=1D0*[xtime(0)-0.01,xtime(0)+xd/2.,xtime(0)+xd/2.,xtime(0)-0.01]
         box_y=1D0*[altO3(0,jalt),altO3(0,jalt),altO3(0,jalt)+yd,altO3(0,jalt)+yd]/1000.
         polyfill,box_x,box_y,color=color_index
       endif
endfor


if (flag eq 1) then begin
   vert_color_bar,0.92,0.5,0.94,0.9,val_col,col,form='(i4)',SIZE_OWN=0.8,THICK_OWN=2
endif


End
;=============================================================================
PRO color_table

red=intarr(256) & green=intarr(256) & blue=intarr(256)

loadct,33,NCOLORS=100
tvlct,r,g,b,/get
red(0:99)=r(0:99) & green(0:99)=g(0:99) & blue(0:99)=b(0:99)

loadct,0,NCOLORS=30
tvlct,r,g,b,/get
red(100:119)=r(10:29) & green(100:119)=g(10:29) & blue(100:119)=b(10:29)


red(255)=255 & green(255)=255 & blue(255)=255 ;set for plot
;red(254)=0 & green(254)=0 & blue(254)=0 ;set for background
red(0)=0 & green(0)=0 & blue(0)=0 ;black color for default
tvlct,red,green,blue
;!P.COLOR=254
;!P.BACKGROUND=255

END
;================================================================================
pro calc_ozone_dobson,rn,alt,temp,o3_mpa,o3_dobson,o3_tot_du

; Declare constants...
DU1=2.69e16 ; [molecules cm^-2 DU^-1]
Av=6.022e23 ; [molecules mol^-1]
R=8.314 ; [J mol^-1 K^-1]
o3_dobson=fltarr(rn)
bad=where(o3_mpa eq -1,count)
if (count ge 1) then o3_mpa(bad)=0.

alt(*)=alt(*)*1e3
o3_pa=o3_mpa/1e3
temp=temp+273.15
c_o3_tot=0.
for ii=0,rn-2 do begin
	dz=(alt(ii+1)-alt(ii))*1e2
	op=(o3_pa(ii)+o3_pa(ii+1))/2.0
	t=(temp(ii)+temp(ii+1))/2.0
	if (alt(ii) ne -1 and alt(ii+1) ne -1) then begin
		c_o3=op*Av*dz/R/t/1e6
		c_o3_tot=c_o3_tot+c_o3
		o3_dobson(ii+1)=c_o3_tot/DU1
;		print,dz,op,t,c_o3,c_o3_tot/DU1
	endif
endfor
o3_tot_du=max(o3_dobson)



end
;=================================================================================
pro tropopause1,temp_arr,press_arr,alt_arr,trop_temp,trop_press,trop_alt;,o3_mpa,o3_ppmv,hum_arr,trop_arr

height=fltarr(1,20)
temp=fltarr(1,20)
press=fltarr(1,20)
o3mpa=fltarr(1,20)
o3ppmv=fltarr(1,20)
trop_arr=fltarr(7,5)
old_lapse=10.0
trop_no=0
for j=0,369 do begin
	if (press_arr(0,j) le 500 and press_arr(0,j) ge 25) then begin
		height=alt_arr(0,j:j+20)
		temp=temp_arr(0,j:j+20)
		press=press_arr(0,j:j+20)
;		o3mpa=o3_mpa(0,j:j+20)
;		o3ppmv=o3_ppmv(0,j:j+20)
;		hum=hum_arr(0,j:j+20)
		;print, height,temp
		cum_height_diff=0.0
		cum_temp_diff=0.0
		for diff=0,18 do begin
			cum_height_diff=cum_height_diff+(height(0,diff+1)-height(0,diff))
			cum_temp_diff=cum_temp_diff+(temp(0,diff+1)-temp(0,diff))
		endfor
		lapse=cum_temp_diff/cum_height_diff*(-1)
		if (old_lapse gt 2.0 and lapse le 2.0) then begin
;			print, '2 km average lapse rate =',old_lapse
;			print, '2 km average lapse rate =',lapse
;			print, 'Tropopause Detected...'
			trop_temp=temp(0,9)
;			print,'Tropopause temperature =',trop_temp
			trop_press=press(0,9)
;			print,'Tropopause pressure =',trop_press
			trop_alt=height(0,9)
;			print,'Tropopause Height =',trop_alt
			if (trop_no lt 5) then begin
				trop_arr(0,trop_no)=trop_temp
				trop_arr(1,trop_no)=trop_press
				trop_arr(2,trop_no)=trop_alt
				trop_arr(3,trop_no)=lapse
;				trop_arr(4,trop_no)=o3mpa(0,9)
;				trop_arr(5,trop_no)=o3ppmv(0,9)
;				trop_arr(6,trop_no)=hum(0,9)
				trop_no=trop_no+1
			endif
		endif
		old_lapse=lapse
	endif
endfor
trop_temp=trop_arr(0,0)
trop_press=trop_arr(1,0)
trop_alt=trop_arr(2,0)


return
end
;=====================================================================
;***********************************************************************************************
;*
;* Routine to read in CDML ozonesonde data and output NetCDF data using Ralf Bennartz's
;* NetCDF write routine...
;* Author: Mohammed Ayoub ATS/UAH	May 2002
;*
;***********************************************************************************************



PRO READ_CMDL_SONDE_NEW,files,nofiles,jday_yr,jday_ytd,press,alt,pottp,temp,$
	ftempv,hum,o3_mpa,o3_ppmv,o3_atmcm,ptemp,o3_num_dn,o3_res,rn,nolines,ttl,$
	year,month,day,hour,minute,second

; Declare count independant variables...
header=STRARR(14) & header1=STRARR(7) & header2=STRARR(7) & str='' & mon=0.
ttl=STRARR(nofiles) & nolines=FLTARR(nofiles) & BV=!VALUES.F_NAN


;kuang, header array changed (increasing one more row)
header_new=STRARR(15)
hd1=STRARR(14)


header1_new=STRARR(8)
hd2=STRARR(7)

PRINT,'Determining array sizes...'
FOR count=0,nofiles-1 DO BEGIN
	OPENR,LUN,files[count],/GET_LUN
;	READF,LUN,header_new ;kuang
    READF,LUN,hd1
	;header(0:2)=header_new(0:2) ;kuang
	;header(3:13)=header_new(4:14) ;kuang
    if (STRLEN(hd1(6)) le 25) then begin
	    header(0:2)=hd1(0:2)  ;for data before HU256 (255, 254.....)
	    header(3:13)=hd1(3:13) ;
	endif else begin
	    header(0:2)=hd1(0:2)
	    header(3:12)=hd1(4:13)
	    READF,LUN,str
	    READF,LUN,str
	endelse

	ttl1=header(7) & ttl2=header(8)
	ttl(count)=ttl1+',  '+ttl2

	; Count the number of data lines in the data file...
	counter=0 ;& line=''
	WHILE (NOT EOF(LUN)) DO BEGIN
		READF,LUN,line
		counter=counter+1
	ENDWHILE
	nolines(count)=counter
	FREE_LUN,LUN
ENDFOR
rn=MAX(nolines)

; Declare count dependant variables...
jday_yr=FLTARR(nofiles) & jday_ytd=jday_yr & year=jday_yr & month=jday_yr & day=jday_yr
hour=jday_yr & minute=jday_yr & second=jday_yr & press=FLTARR(nofiles,rn) & press(*,*)=BV
alt=press & pottp=press & temp=press & ftempv=press & hum=press & o3_mpa=press
o3_ppmv=press & o3_atmcm=press & ptemp=press & o3_num_dn=press & o3_res=press
line=''

PRINT,'Reading in data and removing bad data...'
FOR count=0,nofiles-1 DO BEGIN
	OPENR,LUN,files[count],/GET_LUN

	;READF,LUN,header1_new
	READF,LUN,hd2
	  ;header1(0:2)=header1_new(0:2) ;kuang
	  ;header1(3:6)=header1_new(4:7) ;kuang
	  ;header1(0:2)=header1_new(0:2) ;kuang
	  ;header1(3:6)=header1_new(4:7) ;kuang
	; Read the time, day, month and year to calculate Julian day...
	if (STRLEN(hd2(6)) le 25) then begin
	    READF,LUN,str   ;for data before HU256 (255, 254.....)
	endif else begin
	    READF,LUN,str
	    READF,LUN,str
	endelse

	READF,LUN,hour1,minute1,second1,format='(16x,i2,1x,i2,1x,i2)'
	hour(count)=hour1 & minute(count)=minute1 & second(count)=second1
	sec=((hour1*3600)+(minute1*60)+second1)
	len=STRLEN(str) & newlen=len-24 & day1=FLOAT(STRMID(str,16,2))
	year1=FLOAT(STRMID(str,20+newlen,4))
	;----kuang------
    if (day1 lt 10) then begin
     month1=STRMID(str,18,newlen+1)
    endif else begin
	 month1=STRMID(str,19,newlen)
	endelse
	month1=strtrim(month1,2) ;add 3/25/2010
	;----kuang-------
	IF (month1 EQ 'January') THEN mon=1.
	IF (month1 EQ 'February') THEN mon=2.
	IF (month1 EQ 'March') THEN mon=3.
	IF (month1 EQ 'April') THEN mon=4.
	IF (month1 EQ 'May') THEN mon=5.
	IF (month1 EQ 'June') THEN mon=6.
	IF (month1 EQ 'July') THEN mon=7.
	IF (month1 EQ 'August') THEN mon=8.
	IF (month1 EQ 'September') THEN mon=9.
	IF (month1 EQ 'October') THEN mon=10.
	IF (month1 EQ 'November') THEN mon=11.
	IF (month1 EQ 'December') THEN mon=12.
	year(count)=year1 & month(count)=mon & day(count)=day1
	tempday=1D0*(JULDAY(mon,day1,year1,0,0,second1)-JULDAY(1,1,year1,0,0,0))
	jday_yr(count,0)=tempday+1.+(sec/86400.)
	jday_ytd(count,0)=(tempday+1.)/365.25+year1
	print,year1,mon,day1,hour1,minute1,second1,jday_ytd(count,0)
  	POINT_LUN,LUN,0
	;READF,LUN,header_new ;kuang
	READF,LUN,hd1 ;kuang
    if (STRLEN(hd2(6)) le 25) then begin
	  header(0:13)=hd1(0:13)  ;for data before HU256 (255, 254.....)
	endif else begin
	  header(0:2)=hd1(0:2) ;kuang
	  header(3:12)=hd1(4:13) ;kuang
	  READF,LUN,str
	endelse



	;IF (mon EQ 11 AND day1 LE 2) THEN BEGIN
	;	data=FLTARR(15,nolines(count))
	;ENDIF ELSE BEGIN
		data=FLTARR(13,nolines(count))
	;ENDELSE
	READF,LUN,data
	FREE_LUN,LUN
	; Remove bad data...
	FOR j=0,12 DO BEGIN
		FOR k=0,nolines(count)-1 DO BEGIN
			IF (data(4,k) LE -9999) THEN data(4,k)=BV
			;IF (data(j,k) GE 999 OR data(j,k) LE -999) THEN data(j,k)=BV
			IF (data(3,k) GE 999) THEN data(3,k)=BV
			IF (data(5,k) GE 999) THEN data(5,k)=BV
			IF (data(6,k) GE 999) THEN data(6,k)=BV
			IF (data(7,k) EQ 99999) THEN data(7,k)=BV
			IF (data(8,k) EQ 99999999) THEN data(8,k)=BV
			IF (data(11,k) EQ 999999) THEN data(11,k)=BV
			IF (data(12,k) LT 0) THEN data(12,k)=BV
		ENDFOR
	ENDFOR

	; Write data to storage arrays...
	alt(count,0:nolines(count)-1)=data(2,*)
	press(count,0:nolines(count)-1)=data(1,*)
	pottp(count,0:nolines(count)-1)=data(3,*)
	temp(count,0:nolines(count)-1)=data(4,*)
	ftempv(count,0:nolines(count)-1)=data(5,*)
	hum(count,0:nolines(count)-1)=data(6,*)
	o3_mpa(count,0:nolines(count)-1)=data(7,*)
	o3_ppmv(count,0:nolines(count)-1)=data(8,*)
	o3_atmcm(count,0:nolines(count)-1)=data(9,*)
	ptemp(count,0:nolines(count)-1)=data(10,*)
	o3_num_dn(count,0:nolines(count)-1)=data(11,*)
	o3_res(count,0:nolines(count)-1)=data(12,*)
ENDFOR

;Sort the arrays in chronological order...
PRINT,'Sorting data in chronological order...'
chron=SORT(jday_ytd); sort by year (YYYY.xxx)...
;chron=SORT(jday_yr); sort by julian day of year (DDD)...
year1=year & month1=month & day1=day & hour1=hour & minute1=minute & second1=second
jday_yr1=jday_yr & jday_ytd1=jday_ytd & alt1=alt & pottp1=pottp & temp1=temp
ftempv1=ftempv & hum1=hum & o3_mpa1=o3_mpa & o3_ppmv1=o3_ppmv & o3_atmcm1=o3_atmcm
ptemp1=ptemp & o3_num_dn1=o3_num_dn & o3_res1=o3_res & press1=press & ttl1=ttl
FOR count=0,nofiles-1 DO BEGIN
	jday_yr(count)=jday_yr1(chron(count))
	jday_ytd(count)=jday_ytd1(chron(count))
	year(count)=year1(chron(count))
	month(count)=month1(chron(count))
	day(count)=day1(chron(count))
	hour(count)=hour1(chron(count))
	minute(count)=minute1(chron(count))
	second(count)=second1(chron(count))
	alt(count,*)=alt1(chron(count),*)
	pottp(count,*)=pottp1(chron(count),*)
	temp(count,*)=temp1(chron(count),*)
	ftempv(count,*)=ftempv1(chron(count),*)
	hum(count,*)=hum1(chron(count),*)
	o3_mpa(count,*)=o3_mpa1(chron(count),*)
	o3_ppmv(count,*)=o3_ppmv1(chron(count),*)
	o3_atmcm(count,*)=o3_atmcm1(chron(count),*)
	ptemp(count,*)=ptemp1(chron(count),*)
	o3_num_dn(count,*)=o3_num_dn1(chron(count),*)
	o3_res(count,*)=o3_res1(chron(count),*)
	press(count,*)=press1(chron(count),*)
	ttl(count)=ttl1(chron(count))
ENDFOR


END
;=======================================================================

;
files=FILE_SEARCH('C:\Users\Wes Cantrell\Desktop\LE1', '*.LE1', count=numfiles)


o3mr=FLTARR(numfiles, 2000)  & o3mr[*,*]=!VALUES.F_NAN
alt=o3mr  
temp=o3mr
press=o3mr
hum=o3mr
date=STRARR(numfiles)
time=STRARR(numfiles)
hour=FLTARR(numfiles)
minute=hour
second=hour
day=hour
month=hour
year=hour
jday_yr=FLTARR(numfiles)
jday_ytd=FLTARR(numfiles)



FOR j=0, numfiles-1 DO BEGIN

read_sonde_le1, numfiles, files[j], array_size, range, flight_num, date_read, time_read $
              , station, o3_read, alt_read, press_read, temp_read, hum_read

o3mr[j,*]=o3_read[*]
alt[j,*]=alt_read[*]
temp[j,*]=temp_read[*]
press[j,*]=press_read[*]
hum[j,*]=hum_read[*]
time[j]=time_read
date[j]=date_read


hour1=FLOAT(STRMID(time_read,0,2)) & minute1=FLOAT(STRMID(time_read,3,2)) & second1=FLOAT(STRMID(time_read,6,2))


  hour(j)=hour1 & minute(j)=minute1 & second(j)=second1
  sec=((hour1*3600)+(minute1*60)+second1)
  
  day1=FLOAT(STRMID(date_read,0,2))
  year1=FLOAT(STRMID(date_read,3,4,/REVERSE_OFFSET))
  
  ;----kuang------
    if (day1 lt 10) then begin
      month1=STRMID(date_read, 2,3)
    endif else begin
      month1=STRMID(date_read,3,3)
    endelse
    
 ; month1=strtrim(month1,2) ;add 3/25/2010
  
  ;----kuang-------
  IF (month1 EQ 'Jan') THEN mon=1.
  IF (month1 EQ 'Feb') THEN mon=2.
  IF (month1 EQ 'Mar') THEN mon=3.
  IF (month1 EQ 'Apr') THEN mon=4.
  IF (month1 EQ 'May') THEN mon=5.
  IF (month1 EQ 'Jun') THEN mon=6.
  IF (month1 EQ 'Jul') THEN mon=7.
  IF (month1 EQ 'Aug') THEN mon=8.
  IF (month1 EQ 'Sep') THEN mon=9.
  IF (month1 EQ 'Oct') THEN mon=10.
  IF (month1 EQ 'Nov') THEN mon=11.
  IF (month1 EQ 'Dec') THEN mon=12.
  year(j)=year1 & month(j)=mon & day(j)=day1
  tempday=1D0*(JULDAY(mon,day1,year1,0,0,second1)-JULDAY(1,1,year1,0,0,0))
  jday_yr(j,0)=tempday+1.+(sec/86400.)
  jday_ytd(j,0)=(tempday+1.)/365.25+year1



ENDFOR

nofiles=numfiles
print, files, nofiles
o3_ppmv=o3mr

;Sort the arrays in chronological order...
PRINT,'Sorting data in chronological order...'
chron=SORT(jday_ytd); sort by year (YYYY.xxx)...
;chron=SORT(jday_yr); sort by julian day of year (DDD)...
year1=year & month1=month & day1=day & hour1=hour & minute1=minute & second1=second
jday_yr1=jday_yr & jday_ytd1=jday_ytd & alt1=alt & temp1=temp
hum1=hum & o3_ppmv1=o3_ppmv & press1=press 
FOR count=0,nofiles-1 DO BEGIN
  jday_yr(count)=jday_yr1(chron(count))
  jday_ytd(count)=jday_ytd1(chron(count))
  year(count)=year1(chron(count))
  month(count)=month1(chron(count))
  day(count)=day1(chron(count))
  hour(count)=hour1(chron(count))
  minute(count)=minute1(chron(count))
  second(count)=second1(chron(count))
  alt(count,*)=alt1(chron(count),*)
  temp(count,*)=temp1(chron(count),*)
  hum(count,*)=hum1(chron(count),*)
  o3_ppmv(count,*)=o3_ppmv1(chron(count),*)
  press(count,*)=press1(chron(count),*)
ENDFOR








set_plot, 'ps'
device, file='C:\Users\Wes Cantrell\Desktop\LE1\temp_profiles.ps', /color
!p.multi=[0,2,2]

temp_test=FLTARR(numfiles)
FOR p=0, numfiles-1 DO BEGIN

  temp_test[p]=temp[p,WHERE(alt[p,*] EQ 19)]

  plot, temp[p,*], alt[p,*], yrange=[0,20], title=p


ENDFOR
device, /close




; Tropopause calcualtions using WMO definition...
print,'Calculating tropopause using WMO definition...'
trop_hgt=fltarr(nofiles)
for i=0,nofiles-1 do begin
	tropopause1,temp(i,*),press(i,*),alt(i,*),trop_temp,trop_press,trop_alt
	trop_hgt(i)=trop_alt
endfor

;print,'Calculating total ozone values in DU...'
;o3_dobson=fltarr(nofiles,rn)
;o3_total_dobson=fltarr(nofiles)
;for i=0,nofiles-1 do begin
;	calc_ozone_dobson,rn,alt(i,*),temp(i,*),o3_mpa(i,*),o3_dob,o3_tot_du
;	o3_dobson(i,*)=o3_dob
;	o3_total_dobson(i)=o3_tot_du
;endfor

; Commence plotting data...
print,'Commence plotting data...'
set_plot,'ps'
;set_plot,'win'

device,file='C:\Users\Wes Cantrell\Desktop\LE1\hsv_sonde_le1.ps',/color,$
xoffset=.5,yoffset=.5,xsize=7.5,ysize=10,/inches,/portrait
!p.charsize=1.2 & !p.thick=2.0 & !x.thick=2.0 & !y.thick=2.0
!p.charthick=2.0 & !p.multi=[0,1,1]

color_table
;restore, 'c:\Kuang\kuang\idl\lib\colors.dat' & tvlct,r,g,b

;col=[0,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25] ;ozone mixing ratio
;col1=[0,6,7,8,9,10,11,12,13,14,15,16]  ;relative humidity
;col2=[6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25] ;mpa
;col3=[6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25]  ;Temperature
;col4=[6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25]  ;Ptential Temperature
;col5=[6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25]  ;Ozone Number Density
;col6=[6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23]  ;Total Tropospheric Ozone (DU)
;col7=[6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25]  ;Total Tropospheric Ozone (DU)

;val=[-999,0,10,20,30,40,50,60,70,80,90,100,125,150,175,200,250,300,350,400] ;omr
;val1=[-999,1,10,20,30,40,50,60,70,80,90,100] ;relative humidity
;val2=[0,5,10,15,20,25,30,35,40,45,50,55,60,65,70,75,80,90,100,110]  ;mpa
;val3=[-80,-74,-68,-62,-56,-50,-44,-38,-32,-26,-20,-14,-8,-2,4,10,16,22,28,34]  ;Temperature
;val4=[270,280,290,300,310,320,330,340,350,360,365,370,375,380,385,390,395,400,405,410]  ;Potential Temperature
;val5=[1,2,3,4,5,6,7,8,9,10,11,12,13,15,17,19,21,23,25,27]  ;Ozone Nuber Density
;val6=[0,10,20,30,40,50,60,70,80,90]  ;Total Ozone (DU)
;val7=[0,5,10,15,20,23,27,30,33,37,40,43,47,50,53,57,60,65]  ;Total Ozone (DU)




mn=['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec',' ']

;q=72
q=180
jmn=min(jday_ytd)
jmx=max(jday_ytd)
maxgap=0.04;     0.041



bad=finite(o3_ppmv)  & bad=where(bad eq 0) & o3_ppmv(bad)=-999
;bad=finite(o3_num_dn)  & bad=where(bad eq 0) & o3_num_dn(bad)=-999

;-----remove alt bad value----
;alt_ind=where((alt le -1), count)
;if(count ge 1) then alt(alt_ind)=-999

;hum_ind=where((hum le -1), count)
;if(count ge 1) then hum(hum_ind)=-999
;-----------------------------

;---interpolate on the regular grids----
ny=350
nx=n_elements(jday_ytd)
alt2=findgen(ny)*0.1  ;in km
date2=jday_ytd
O3_ppmv2=fltarr(nx,ny)
;O3_num_dn2=fltarr(nx,ny)
alt_tmp=alt
bad2=finite(alt_tmp)  & bad2=where(bad2 eq 0) & alt_tmp(bad2)=0  ;-999  ; 0

for i=0,nx-1 do begin
  tmp2=o3_ppmv(i,*)
  ;tmp4=o3_num_dn(i,*)
  ;bad3=where(tmp2 lt 0, count) & if(count ge 1) then tmp2(bad3)=0
  ;bad4=where(tmp4 lt 0, count) & if(count ge 1) then tmp4(bad4)=0
  alt_1=alt_tmp(i,*)
  Smooth_O3,tmp2,alt_1,0,100,0,o3_tmp2,alt_tmp2
  ;Smooth_O3,tmp4,alt_1,0,500,0,o3_tmp4,alt_tmp4

  O3_ppmv2(i,*)=interpol(o3_tmp2,alt_tmp2,alt2)
  ;O3_num_dn2(i,*)=interpol(o3_tmp4,alt_tmp4,alt2)
endfor
alt=alt_tmp
;------------------------------

;stop
;-------------------------------
height_range=[0.2,35]  ;km
val1=[-999,0,400,1000,1500,2000,2500,3000,3500,4000,4500,5000,5500,6000,6500,7000,7500,8000,8500]
;val1=[-999,0,10,20,30,40,50,60,70,80,90,100,125,150,175,200,250,300,350,400]
col1=[255, 1, 5,10,20,30,40,50,60,65,69, 73, 77, 81, 85, 89, 93,96, 99]
col3=[255, 1, 5,10,20,30,40,50,60,65,69, 73, 77, 81, 85, 89, 93,96, 99,99]  ;will be used for monthly ppmv ave contour
bar_flag=1 ;1 plot color bar, otherwise not
position=[0.05,0.51,0.9,0.9]
Curtain_pixel,O3_ppmv*1.e3,jday_ytd,alt*1000.,height_range, val1,col1, bar_flag,position


;;contour,o3_ppmv(*,0:q)*1.e3,jday_ytd,alt(*,0:q),/follow,c_colors=col,color=1,ystyle=1,$
;contour,o3_ppmv2(*,0:q)*1.e3,date2,alt2(0:q),c_colors=col,color=1,ystyle=1,$
;xstyle=1,yrange=[0,17], xrange=[jmn,jmx],$         ;xtickn=mn,xticks=12,$
;;xrange=[jmn-0.42/365.25,jmx+1./365.25],$
;;min_value=1.e-6,max_value=10e3 ,$
;title='Ozone Mixing Ratio (ppbv)',/fill,levels=val,$
;position=[0.05,0.5,0.9,0.9]

oplot,jday_ytd,trop_hgt,color=0,psym=-3,thick=3
for i=0,nofiles-2 do begin
	diff=jday_ytd(i+1)-jday_ytd(i)
	if (diff gt maxgap) then begin
	    middle=(jday_ytd(i+1)+jday_ytd(i))/2
		polyfill,[middle+0.01,middle-0.01,middle-0.01,middle+0.01],[-0.2,-0.2,20.2,20.2],color=255
		print,'gap between ',jday_ytd(i),jday_ytd(i+1)
	endif
endfor
oplot,jday_ytd,alt(*,0)*0+0.2,psym=5,color=0

;for i=5,15,5 do begin
;	plots,jmn,i
;	plots,jmx,i,/continue,color=1
;endfor


; Insert station name at top of plot...
xyouts,0.5,0.95,'Ozonesonde Measurements at Huntsville, AL',/normal,ALIGNMENT=0.5,$
color=0,charsize=1.5,charthick=2
;----------------------------------------------------------------------------------

bad=finite(hum) & bad=where(bad eq 0) & hum(bad)=-999

;contour,hum(*,0:q),jday_ytd,alt(*,0:q),/follow,c_colors=col1,color=1,ystyle=1,$
;xstyle=1,yrange=[0,17],xrange=[jmn,jmx],$  ;xtickn=mn,xticks=12,$
;title='Relative Humidity (%)',/fill,levels=val1,$
;position=[0.05,0.05,0.9,0.45]

height_range=[0.2,35]  ;km
val2=[-999,0,10,20,30,40,50,60,70,80,90,100]
;col2=[255, 1,10,20,30,35,40,45,50,55,60]
col2=[255, 1, 5,10,20,30,40,50,60,65,69]
bar_flag2=0 ;1 plot color bar, otherwise not
position2=[0.05,0.05,0.9,0.44]
Curtain_pixel,hum,jday_ytd,alt*1000.,height_range, val2,col2, bar_flag2, position2

oplot,jday_ytd,trop_hgt,color=80,psym=-3,thick=3
for i=0,nofiles-2 do begin
	diff=jday_ytd(i+1)-jday_ytd(i)
	if (diff gt maxgap) then begin
		middle=(jday_ytd(i+1)+jday_ytd(i))/2
		polyfill,[middle+0.01,middle-0.01,middle-0.01,middle+0.01],[-0.2,-0.2,20.2,20.2],color=255
	endif
endfor
oplot,jday_ytd,alt(*,0)*0+0.2,psym=5,color=0


;for i=5,15,5 do begin
;	plots,jmn,i
;	plots,jmx,i,/continue,color=1
;endfor

;xyouts,0.05,0.01,'J* January 2000',/normal,color=1,charsize=1.0
;xyouts,0.015,0.87,'a)',/normal,color=1,charsize=1.5
;xyouts,0.015,0.42,'b)',/normal,color=1,charsize=1.5
;XYOUTS,0.015,-0.01,'Figure 1',/normal,color=1,charsize=1.2,charthick=3
;---calculate average ozone profile---
nn=ny
ave_num=fltarr(nn) ;average number density,10^11/cm3
ave_ppmv=fltarr(nn) ;average pressure ppmv
sigma_ppmv=fltarr(nn) ;std dev
sigma_num=fltarr(nn) ;std dev
;index1=where(o3_ppmv2 le 0 or o3_ppmv2 gt 100, count)
;o3_ppmv2(index1)= !VALUES.F_NAN
;index2=where(o3_num_dn2 le 0 or o3_num_dn2 gt 500, count2)
;o3_num_dn2(index2)= !VALUES.F_NAN
;print,'o3_ppmv problematic index',count

for i=0,nn-1 do begin
  ;ave_num(i)=mean(o3_num_dn2(*,i),/NAN)
  ave_ppmv(i)=mean(o3_ppmv2(*,i),/NAN)
  ;sigma_num(i)=stddev(o3_num_dn2(*,i),/NAN)
  sigma_ppmv(i)=stddev(o3_ppmv2(*,i),/NAN)
endfor

device,/color,/inches,/portrait,xoffset=0.5,yoffset=0.5,xsize=7.5, ysize=9.5
  !p.thick=4.0 & !x.thick=2.0 & !y.thick=2.0 & !p.charsize=1.4 & !p.multi=[0,1,1] & !p.charthick=2.0
plot,ave_num/10.,alt2,xrange=[0,2],yrange=[0.2,17],title='!6',$
     xstyle=8,ystyle=1,color=1,$
     ytitle='Alt (km)',xtitle='O3 Number Density (10!U12 !Nmolecule cm!U-3!N)',$
     position=[0.3,0.45,0.9,0.9]
     axis,0,17,xaxis=1,XRANGE = [0,200],xstyle=1,xtitle='O3 Volume Mixing Ratio (ppbv)',color=1
     ;oplot,(ave_num+sigma_num)/10.,alt2,linestyle=0,color=120
     ;oplot,(ave_num-sigma_num)/10.,alt2,linestyle=0,color=120
     oplot,ave_ppmv*10.,alt2,linestyle=2,color=1
     oplot,(ave_ppmv-sigma_ppmv)*10.,alt2,linestyle=2,color=120
     oplot,(ave_ppmv+sigma_ppmv)*10.,alt2,linestyle=2,color=120
     xyouts,1.3,9-0.2,'# Density',color=1,size=1.1
     xyouts,1.3,8-0.2,'VMR',color=1,size=1.1
     plots,[1.7, 1.9],[9,9],linestyle=0,color=1
     plots,[1.7, 1.9],[8,8],linestyle=2,color=1
;----temperature-----------------------
temp_avg=fltarr(nn)
temp_stddev=fltarr(nn)
for i=0,nn-1 do begin
  temp_avg(i)=mean(temp(*,i),/NAN)
  temp_stddev(i)=stddev(temp(*,i),/NAN)
endfor

plot,temp_avg,alt2,xrange=[-80,30],yrange=[1.,35],title='!6Temperature Profile',$
     xstyle=1,ystyle=1,color=1,thick=5,/nodata,$
     ytitle='Alt (km)',xtitle='T (!UO!NC)',$
     position=[0.1,0.3,0.9,0.9]
   for i=0,nofiles-1 do begin
   ;test=WHERE(temp[i,WHERE(alt2[i,*] EQ 17)] GT -50)
   ; if test[0] NE -1 then stop
     oplot,temp(i,0:nn-1),alt(0,0:nn-1),thick=1,color=1
   endfor
   oplot,temp_avg,alt(0,0:nn-1),color=18,thick=5

plot,temp_avg,alt2,xrange=[-80,30],yrange=[1.,35],title='!6Mean Temperature Profile over Huntsville',$
     xstyle=1,ystyle=1,color=1,$
     ytitle='Alt (km)',xtitle='T (!UO!NC)',$
     position=[0.1,0.3,0.9,0.9]
   oplot,temp_avg+temp_stddev,alt(0,0:nn-1),linestyle=1,thick=0.6,color=1
   oplot,temp_avg-temp_stddev,alt(0,0:nn-1),linestyle=1,thick=0.6,color=1
;--------------------------------------
;write file
;openw,10,out_ave_o3
;printf,10,'Mean Ozone Profile at Huntsville'
;printf,10,'  Alt(Km) ', '   O3 Number Density(10^11/cm3)', ' O3 pressure (ppmv)'
;for i=0,nn-1 do begin
  ;printf,10,alt(0,i),ave_num(i),ave_ppmv(i)
;endfor
;close,10
;--------------------------------------

ave_ppmv2=fltarr(12,nn) ;monthly average mixing ratio, ppmv
sigma_ppmv2=fltarr(12,nn) ;std dev
mon_i=findgen(12)+1.
mon_f=mon_i/12.
tmp_ave2=fltarr(ny)

;For Jan.
index_mon=where( (jday_ytd mod 1) le mon_f(0) )
for iy=0,ny-1 do begin
     ave_ppmv2(0,iy)=mean(o3_ppmv2(index_mon,iy),/NAN)
     sigma_ppmv2(0,iy)=stddev(o3_ppmv2(index_mon,iy),/NAN)
endfor
;from Feb. to Dec.
for im=1, 11 do begin
   index_mon=where( ((jday_ytd mod 1) le mon_f(im)) and ((jday_ytd mod 1) gt mon_f(im-1)) )
   for iy=0,ny-1 do begin
     ave_ppmv2(im,iy)=mean(o3_ppmv2(index_mon,iy),/NAN)
     sigma_ppmv2(im,iy)=stddev(o3_ppmv2(index_mon,iy),/NAN)
   endfor
endfor
;monthly average ozone in ppbv
contour,ave_ppmv2*1.e3,mon_i,alt2,/FILL,$
             yrange=[0.2,35],xstyle=1,ystyle=1,Position=[0.05,0.2,0.85,0.8],$
             xtitle='!6Month',ytitle='Alt (km)',title='!6Monthly average O!D3 !N(ppbv)',$
             levels=val1,c_colors=col3
   vert_color_bar,0.92,0.2,0.94,0.8,val1,col1,form='(i4)',SIZE_OWN=0.8,THICK_OWN=2

;monthly standard deviation in %
val5=(findgen(20)+1)*5
col5=(indgen(20)+1)*5-1
val5_2=indgen(21)*5
dev_ppmv2=sigma_ppmv2/ave_ppmv2*100.
;bad=finite(dev_ppmv2)  & bad=where(bad eq 0) & dev_ppmv2(bad)=0  ;remove infinity due to zero denominator
contour,dev_ppmv2,mon_i,alt2,/FILL,$
             yrange=[0.2,35],xstyle=1,ystyle=1,Position=[0.05,0.2,0.85,0.8],$
             xtitle='!6Month',ytitle='Alt (km)',title='!6Standard deviation (%)',$
             ;MAX_VALUE=100,min_VALUE=0,$
             levels=val5,c_colors=col5
   vert_color_bar,0.92,0.2,0.94,0.8,val5_2,col5,form='(i4)',SIZE_OWN=0.8,THICK_OWN=2

SAVE, /VARIABLES, FILENAME = 'hsv-sonde-99-09.dat'


print, 'plot complete!  Done.'
;---output date and time for OMI-----2011/3/21----
SAVE, files,year,month,day,hour,minute,second, FILENAME = 'HSV_sonde_date.xdr'
;-------------------------------------------------

device, /close
stop
;!p.region=0
;!p.multi=0

end