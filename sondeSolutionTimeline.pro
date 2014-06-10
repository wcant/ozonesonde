FUNCTION read_sonde_de1, file $
  , VARNAMES=varnames
  
  
  ;Define data structure to which each file's contents will be appended to
  data = {ftime:'', fdate:''}
  
  nlines=FILE_LINES(file)
  dum=STRARR(nlines)
  
  OPENR, lun, file, /GET_LUN
  READF, lun, dum
  FREE_LUN, lun

  ;extract date and launch time of flight
  data.ftime=dum[4]
  data.fdate=dum[3]
  
  ;get var names
  offset=2
  the_vars=dum[offset:*]
  ;split into array of var names
  the_vars=STRSPLIT(the_vars,'=', /extract)

  varnames = STRARR(nlines-offset)
  values = STRARR(nlines-offset)
  
  i=0
  FOREACH element, the_vars DO BEGIN
    varnames[i] = element[0]
    values[i] = element[1]
    i++
  ENDFOREACH
  
 ; nsize=SIZE(dum[0,*], /dimensions)
 
  ;alphabetize the varnames
  sort_vars=SORT(varnames)

  data=CREATE_STRUCT(data,"varnames",varnames[sort_vars], "values", values[sort_vars])
  
  RETURN, data

END

PRO sondeSolutionTimeline
  
  files = FILE_SEARCH("C:\Users\Wes\Dropbox\Sonde Data\Huntsville\Database_rebuild\HU???\DATA\", "?????.de1")
  data = { files:file, nfiles:N_ELEMENTS(files) }
  FOREACH element, file DO BEGIN
     getTag = STRSPLIT(element, '\', /extract)
     data = CREATE_STRUCT(data, getTag[6], read_sonde_de1(element, varnames = varnames))
  ENDFOREACH

  stop
END