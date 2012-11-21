; haribote-os boot asm
; TAB=4

BOTPAK	EQU		0x00280000		; bootpack‚Ìƒ[ƒhæ
DSKCAC	EQU		0x00100000		; ƒfƒBƒXƒNƒLƒƒƒbƒVƒ…‚ÌêŠ
DSKCAC0	EQU		0x00008000		; ƒfƒBƒXƒNƒLƒƒƒbƒVƒ…‚ÌêŠiƒŠƒAƒ‹ƒ‚[ƒhj

; BOOT_INFOŠÖŒW
CYLS	EQU		0x0ff0			; ƒu[ƒgƒZƒNƒ^‚ªÝ’è‚·‚é
LEDS	EQU		0x0ff1
VMODE	EQU		0x0ff2			; F”‚ÉŠÖ‚·‚éî•ñB‰½ƒrƒbƒgƒJƒ‰[‚©H
SCRNX	EQU		0x0ff4			; ‰ð‘œ“x‚ÌX
SCRNY	EQU		0x0ff6			; ‰ð‘œ“x‚ÌY
VRAM	EQU		0x0ff8			; ƒOƒ‰ƒtƒBƒbƒNƒoƒbƒtƒ@‚ÌŠJŽn”Ô’n

		ORG		0xc200			; ‚±‚ÌƒvƒƒOƒ‰ƒ€‚ª‚Ç‚±‚É“Ç‚Ýž‚Ü‚ê‚é‚Ì‚©

; ‰æ–Êƒ‚[ƒh‚ðÝ’è

		MOV		AL,0x13			; VGAƒOƒ‰ƒtƒBƒbƒNƒXA320x200x8bitƒJƒ‰[
		MOV		AH,0x00
		INT		0x10
		MOV		BYTE [VMODE],8	; ‰æ–Êƒ‚[ƒh‚ðƒƒ‚‚·‚éiCŒ¾Œê‚ªŽQÆ‚·‚éj
		MOV		WORD [SCRNX],320
		MOV		WORD [SCRNY],200
		MOV		DWORD [VRAM],0x000a0000

; ƒL[ƒ{[ƒh‚ÌLEDó‘Ô‚ðBIOS‚É‹³‚¦‚Ä‚à‚ç‚¤

		MOV		AH,0x02
		INT		0x16 			; keyboard BIOS
		MOV		[LEDS],AL

; PIC‚ªˆêØ‚ÌŠ„‚èž‚Ý‚ðŽó‚¯•t‚¯‚È‚¢‚æ‚¤‚É‚·‚é
;	ATŒÝŠ·‹@‚ÌŽd—l‚Å‚ÍAPIC‚Ì‰Šú‰»‚ð‚·‚é‚È‚çA
;	‚±‚¢‚Â‚ðCLI‘O‚É‚â‚Á‚Ä‚¨‚©‚È‚¢‚ÆA‚½‚Ü‚Éƒnƒ“ƒOƒAƒbƒv‚·‚é
;	PIC‚Ì‰Šú‰»‚Í‚ ‚Æ‚Å‚â‚é

		MOV		AL,0xff
		OUT		0x21,AL
		NOP						; OUT–½—ß‚ð˜A‘±‚³‚¹‚é‚Æ‚¤‚Ü‚­‚¢‚©‚È‚¢‹@Ží‚ª‚ ‚é‚ç‚µ‚¢‚Ì‚Å
		OUT		0xa1,AL

		CLI						; ‚³‚ç‚ÉCPUƒŒƒxƒ‹‚Å‚àŠ„‚èž‚Ý‹ÖŽ~

; CPU‚©‚ç1MBˆÈã‚Ìƒƒ‚ƒŠ‚ÉƒAƒNƒZƒX‚Å‚«‚é‚æ‚¤‚ÉAA20GATE‚ðÝ’è

		CALL	waitkbdout
		MOV		AL,0xd1
		OUT		0x64,AL
		CALL	waitkbdout
		MOV		AL,0xdf			; enable A20
		OUT		0x60,AL
		CALL	waitkbdout

; ƒvƒƒeƒNƒgƒ‚[ƒhˆÚs

[INSTRSET "i486p"]				; 486‚Ì–½—ß‚Ü‚ÅŽg‚¢‚½‚¢‚Æ‚¢‚¤‹Lq

		LGDT	[GDTR0]			; Žb’èGDT‚ðÝ’è
		MOV		EAX,CR0
		AND		EAX,0x7fffffff	; bit31‚ð0‚É‚·‚éiƒy[ƒWƒ“ƒO‹ÖŽ~‚Ì‚½‚ßj
		OR		EAX,0x00000001	; bit0‚ð1‚É‚·‚éiƒvƒƒeƒNƒgƒ‚[ƒhˆÚs‚Ì‚½‚ßj
		MOV		CR0,EAX
		JMP		pipelineflush
pipelineflush:
		MOV		AX,1*8			;  “Ç‚Ý‘‚«‰Â”\ƒZƒOƒƒ“ƒg32bit
		MOV		DS,AX
		MOV		ES,AX
		MOV		FS,AX
		MOV		GS,AX
		MOV		SS,AX

; bootpack‚Ì“]‘—

		MOV		ESI,bootpack	; “]‘—Œ³
		MOV		EDI,BOTPAK		; “]‘—æ
		MOV		ECX,512*1024/4
		CALL	memcpy

; ‚Â‚¢‚Å‚ÉƒfƒBƒXƒNƒf[ƒ^‚à–{—ˆ‚ÌˆÊ’u‚Ö“]‘—

; ‚Ü‚¸‚Íƒu[ƒgƒZƒNƒ^‚©‚ç

		MOV		ESI,0x7c00		; “]‘—Œ³
		MOV		EDI,DSKCAC		; “]‘—æ
		MOV		ECX,512/4
		CALL	memcpy

; Žc‚è‘S•”

		MOV		ESI,DSKCAC0+512	; “]‘—Œ³
		MOV		EDI,DSKCAC+512	; “]‘—æ
		MOV		ECX,0
		MOV		CL,BYTE [CYLS]
		IMUL	ECX,512*18*2/4	; ƒVƒŠƒ“ƒ_”‚©‚çƒoƒCƒg”/4‚É•ÏŠ·
		SUB		ECX,512/4		; IPL‚Ì•ª‚¾‚¯·‚µˆø‚­
		CALL	memcpy

; asmhead‚Å‚µ‚È‚¯‚ê‚Î‚¢‚¯‚È‚¢‚±‚Æ‚Í‘S•”‚µI‚í‚Á‚½‚Ì‚ÅA
;	‚ ‚Æ‚Íbootpack‚É”C‚¹‚é

; bootpack‚Ì‹N“®

		MOV		EBX,BOTPAK
		MOV		ECX,[EBX+16]
		ADD		ECX,3			; ECX += 3;
		SHR		ECX,2			; ECX /= 4;
		JZ		skip			; “]‘—‚·‚é‚×‚«‚à‚Ì‚ª‚È‚¢
		MOV		ESI,[EBX+20]	; “]‘—Œ³
		ADD		ESI,EBX
		MOV		EDI,[EBX+12]	; “]‘—æ
		CALL	memcpy
skip:
		MOV		ESP,[EBX+12]	; ƒXƒ^ƒbƒN‰Šú’l
		JMP		DWORD 2*8:0x0000001b

waitkbdout:
		IN		 AL,0x64
		AND		 AL,0x02
		JNZ		waitkbdout		; AND‚ÌŒ‹‰Ê‚ª0‚Å‚È‚¯‚ê‚Îwaitkbdout‚Ö
		RET

memcpy:
		MOV		EAX,[ESI]
		ADD		ESI,4
		MOV		[EDI],EAX
		ADD		EDI,4
		SUB		ECX,1
		JNZ		memcpy			; ˆø‚«ŽZ‚µ‚½Œ‹‰Ê‚ª0‚Å‚È‚¯‚ê‚Îmemcpy‚Ö
		RET
; memcpy‚ÍƒAƒhƒŒƒXƒTƒCƒYƒvƒŠƒtƒBƒNƒX‚ð“ü‚ê–Y‚ê‚È‚¯‚ê‚ÎAƒXƒgƒŠƒ“ƒO–½—ß‚Å‚à‘‚¯‚é

		ALIGNB	16
GDT0:
		RESB	8				; ƒkƒ‹ƒZƒŒƒNƒ^
		DW		0xffff,0x0000,0x9200,0x00cf	; “Ç‚Ý‘‚«‰Â”\ƒZƒOƒƒ“ƒg32bit
		DW		0xffff,0x0000,0x9a28,0x0047	; ŽÀs‰Â”\ƒZƒOƒƒ“ƒg32bitibootpack—pj

		DW		0
GDTR0:
		DW		8*3-1
		DD		GDT0

		ALIGNB	16
bootpack:
