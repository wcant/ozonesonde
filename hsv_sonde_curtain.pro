PRO HSV_sonde_curtain

files=FILE_SEARCH('C:\Users\Wes Cantrell\Desktop\LE1', '*.LE1', count=numfiles)


o3mr=FLTARR(numfiles, 2000)  & o3mr[*,*]=!VALUES.F_NAN
alt=o3mr  
temp=o3mr
press=o3mr
date=FLTARR(numfiles)
time=FLTARR(numfiles)

FOR j=0, numfiles-1 DO BEGIN

read_sonde_le1, numfiles, files[j], array_size, range, flight_num, date_read, time_read $
              , station, o3_read, alt_read, press_read, temp_read

o3mr[j,*]=o3_read[*]
alt[j,*]=alt_read[*]
temp[j,*]=temp_read[*]
press[j,*]=press_read[*]
time[j]=time_read
date[j]=date_read

ENDFOR



stop



END
