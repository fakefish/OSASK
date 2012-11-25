; haribote-os boot asm
; TAB=4

BOTPAK	EQU		0x00280000		; 
DSKCAC	EQU		0x00100000		; 
DSKCAC0	EQU		0x00008000		; 

; 有关BOOT-INFO
CYLS	EQU		0x0ff0			; 设定启动区
LEDS	EQU		0x0ff1
VMODE	EQU		0x0ff2			; 关于颜色数目的信息。颜色的位数
SCRNX	EQU		0x0ff4			; screen X
SCRNY	EQU		0x0ff6			; screen Y
VRAM	EQU		0x0ff8			; 图像缓冲区的开始地址

		ORG		0xc200			; 



		MOV		AL,0x13			; VGA显卡， 320x200x8位彩色
		MOV		AH,0x00
		INT		0x10
		MOV		BYTE [VMODE],8	; 记录画面模式
		MOV		WORD [SCRNX],320
		MOV		WORD [SCRNY],200
		MOV		DWORD [VRAM],0x000a0000

; 用BIOS取得键盘上各种LED指示灯的状态

		MOV		AH,0x02
		INT		0x16 			; keyboard BIOS
		MOV		[LEDS],AL

; PIC关闭一切中断
;	根据AT兼容机的规格，如果要初始化PIC,
;	必须在CLI之前进行，否则有时会挂起
;	随后进行PIC的初始化

		MOV		AL,0xff
		OUT		0x21,AL
		NOP						; 如果连续执行OUT指令，有些机种会无法正常运行
		OUT		0xa1,AL

		CLI						; 禁止CPU级别的中断

; 为了让CPU能够访问1MB以上的内存空间，设定A20GATE

		CALL	waitkbdout
		MOV		AL,0xd1
		OUT		0x64,AL
		CALL	waitkbdout
		MOV		AL,0xdf			; enable A20
		OUT		0x60,AL
		CALL	waitkbdout

; 切换到保护模式

[INSTRSET "i486p"]				; “想要使用486指令”的叙述

		LGDT	[GDTR0]			; 设定临时GDT
		MOV		EAX,CR0
		AND		EAX,0x7fffffff	; 设bit31为0 
		OR		EAX,0x00000001	; 设bit0为1
		MOV		CR0,EAX
		JMP		pipelineflush
pipelineflush:
		MOV		AX,1*8			;  可读写的段 32bit
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
