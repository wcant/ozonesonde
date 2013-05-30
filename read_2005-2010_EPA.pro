;purpose:  Ready EPA data from 2005-2010

dir='C:\Dropbox\EPA Data\2005-2010'
file=FILE_SEARCH(dir, '*.txt', count=count)
IF count EQ 0 THEN STOP

OPENR, lun, file, /GET_LUN

header=STRARR(118)

READF, lun, header

line=STRARR(1)


stop


FREE_LUN, lun

END