PRO low_surface_o3_correction
dat_files='C:\Users\Wes Cantrell\Dropbox\Sonde Data\Huntsville\DAT\all'

files=FILE_SEARCH(dat_files,'*FLT.DAT', count=numfiles)
print, '#files: ', numfiles
;print, files
IF numfiles EQ 0 then begin
      print, 'No ".DAT" files found.'
      stop
ENDIF

Read_DAT_LE1, numfiles, files, array_size, Data, Meta

RESTORE, 'C:\Users\Wes Cantrell\Dropbox\Sonde Data\Huntsville\LE1 files\data\Huntsville-sonde-99-12.dat'

LE1_files=STRMID(Huntsville.files, 67,5)
DAT_files=Meta.flightnum


delete_dat=STRARR(50)

p=0
FOR i=0, N_ELEMENTS(DAT_files)-1 DO BEGIN

  IF WHERE(LE1_files EQ DAT_files[i]) EQ -1 THEN BEGIN
  
    delete_dat[p]=DAT_files[i]
    p++
    
  ENDIF

ENDFOR





stop


le1_o3=FLTARR(3,2000) & le1_o3[*,*]=!VALUES.F_NAN & le1_alt=le1_o3
le1_o3[0,*]=Huntsville.o3mr[655,*]
le1_o3[1,*]=Huntsville.o3mr[656,*]
le1_o3[2,*]=Huntsville.o3mr[657,*]

le1_alt[0,*]=Huntsville.alt[655,*]
le1_alt[1,*]=Huntsville.alt[656,*]
le1_alt[2,*]=Huntsville.alt[657,*]


;Regression
le1_reg=FLTARR(3,2) & le1_reg[*,*]=!VALUES.F_NAN
yfit=FLTARR(3)
le1_reg[0,*]=LINFIT(le1_o3[0,1:2], le1_alt[0,1:2], YFIT=yfit[0])
le1_reg[1,*]=LINFIT(le1_o3[1,1:2], le1_alt[1,1:2], YFIT=yfit[1])
le1_reg[2,*]=LINFIT(le1_o3[2,1:2], le1_alt[2,1:2], YFIT=yfit[2])

x_interp=FLTARR(3)
x_interp[0]=(le1_alt[0,0]-le1_reg[0,0])/le1_reg[0,1]
x_interp[1]=(le1_alt[1,0]-le1_reg[1,0])/le1_reg[1,1]
x_interp[2]=(le1_alt[2,0]-le1_reg[2,0])/le1_reg[2,1]

interp_o3=FLTARR(3,3)
interp_o3[0,*]=[[x_interp[0]],[le1_o3[0,1:2]]]
interp_o3[1,*]=[[x_interp[1]],[le1_o3[1,1:2]]]
interp_o3[2,*]=[[x_interp[2]],[le1_o3[2,1:2]]]

set_plot, 'PS'
device, filename='C:\Dropbox\Sonde Data\Huntsville\surface_correction_analysis\FLT_LE1_correction.ps', /COLOR

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


  ;first_layer=WHERE(Data.alt[0,*] LE 0.2)
  ;second_layer=WHERE(Data.alt[0,*] GT 0.2 and Data.alt[0,*] LE 0.3)
  plot, Data.o3mr[0,*],Data.alt[0,*]  $
      , yrange=[0.190,.6] $
      , xrange=[0,150]  $
      , title='HU740' $
      , color=1
      oplot, le1_o3[0,0:MAX(WHERE(le1_alt[0,*] GE 1))], le1_alt[0,0:MAX(WHERE(le1_alt[0,*] GE 1))] $
           , psym=2 $
           , color=1
      oplot, [interp_o3[0,0],interp_o3[0,0]], [le1_alt[0,0],le1_alt[0,0]] $
           , color=40  $
           , psym=4 

  plot, Data.o3mr[1,*],Data.alt[1,*]  $
      , yrange=[0.190,.6] $
      , xrange=[0,150]  $
      , title='HU743'$
      , color=1
      oplot, le1_o3[1,0:MAX(WHERE(le1_alt[1,*] GE 1))], le1_alt[1,0:MAX(WHERE(le1_alt[1,*] GE 1))] $
           , psym=2 $
           , color=1
      oplot, [interp_o3[1,0],interp_o3[1,0]], [le1_alt[1,0],le1_alt[1,0]] $
           , color=40  $
           , psym=4

  plot, Data.o3mr[2,*],Data.alt[2,*]  $
      , yrange=[0.190,.6] $
      , xrange=[0,150]  $
      , title='HU746' $
      , color=1
      oplot, le1_o3[2,0:MAX(WHERE(le1_alt[2,*] GE 1))], le1_alt[2,0:MAX(WHERE(le1_alt[2,*] GE 1))] $
           , psym=2  $
           , color=1
      oplot, [interp_o3[2,0],interp_o3[2,0]], [le1_alt[2,0],le1_alt[2,0]] $
           , color=40  $
           , psym=4


device, /CLOSE

stop

END