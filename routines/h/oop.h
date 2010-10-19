.include "routines/conf/config.inc"


;defines
.define maxNumberOopObjs	10
;.define oopArrayLength 9
.define oopStackTst	$aa55
.define maxExecTime 10	;number of frames oop handler may spend on a single obj before nmi watchdog throws error

;obj return codes
.ENUM 0	export
OBJR_noErr	db
OBJR_kill	db
.ende

.ENUM 0	export
OOPR.flags	db	;bit0: singleton
OOPR.id			db	;generated by saving number of class macro calls here
OOPR.zpLen	db	;length of required zeropage-buffer
OOPR.rCount	db	;number of routines
OOPR.nClass	db	;relative adress of obj class name
OOPR.rInit	dw	;adress of obj init routine
OOPR.nInit	db	;relative adress of obj init routine name
OOPR.rPlay	dw 	;adress of obj play routine
OOPR.nPlay	db	;relative adress of obj play routine name
OOPR.rKill	dw 	;adress of obj terminate routine
OOPR.nKill	db	;relative adress of obj terminate routine name
OOPR.rAdd		dw 	;adress of obj additional routine
OOPR.nAdd		db	;relative adress of obj additional routine name
.ENDE

.enum 0
Hash INSTANCEOF oopObjHash
.ende

;data structures
.STRUCT oopStackObj
flags		db	;msb:obj present bit0:singleton bit1:persistent(undeletable) bit2:init complete
id			db	;class id
num			dw	;number of createOopObj calls at obj instanciation time. used for fingerprint
pntr		ds 3	;24bit pointer to obj in rom. needed? may be removed
dp			dw	;absolute direct page adress on object variable buffer
init		dw	;obj init subroutine absolute adress
play		dw	;obj play subroutine absolute adress
kill		dw	;obj terminate subroutine absolute adress
.ENDST



;ram buffers
.ramsection "oop ram" bank 0 slot 1
OopStack INSTANCEOF oopStackObj maxNumberOopObjs
OopStackEnd ds 0
.ends

;ram buffers
.ramsection "global oop vars" bank 0 slot 1
classStr		ds 3
routStr			ds 3
execFrame		dw
.ends



.ramsection "oop obj ram zp" bank 0 slot 2
OopObjRam ds $1800
OopObjRamEnd ds 0
.ends

;spit out globally unique obj-ids. order does not matter
.enum 0 export
OBJID.Rng	db
OBJID.Sa1Iface	db
;OBJID.Nmi	db
OBJID.Demo	db
OBJID.Spc	db
OBJID.Script	db
MAXOBJID	ds 0
.ende


.base BSL
.bank 0 slot 0
.section "oop-class lut" superfree
OopClassLut:
	PTRLONG OopClassLut Rng.CLS
	PTRLONG OopClassLut Sa1Iface.CLS
;	PTRLONG OopClassLut Nmi.CLS
	PTRLONG OopClassLut Demo.CLS
	PTRLONG OopClassLut Spc.CLS
	PTRLONG OopClassLut Script.CLS
.ends
