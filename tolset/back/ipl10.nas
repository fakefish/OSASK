; haribote-ipl
; TAB=4

CYLS 	EQU 	10				; like #define in C, CYLS is cylinders

		ORG		0x7c00			; 指明程序的装载地址

; 标准FAT12格式软盘专用代码

		JMP		entry
		DB		0x90
		DB		"HARIBOTE"		; 启动区的名称
		DW		512				; 每个扇区的大小
		DB		1				; size of cluster
		DW		1				; FAT的起始位置
		DB		2				; FAT的个数
		DW		224				; 根目录的大小
		DW		2880			; 该磁盘的大小
		DB		0xf0			; 磁盘的种类
		DW		9				; FAT的长度
		DW		18				; 1个磁道有几个扇区
		DW		2				; 磁头数
		DD		0				; 不使用分区
		DD		2880			; 重写一次磁盘的大小
		DB		0,0,0x29		; 固定
		DD		0xffffffff		; 卷标号码
		DB		"HARIBOTEOS "	; 磁盘的名称
		DB		"FAT12   "		; 磁盘格式名称
		RESB	18				; 空出18个字节

; 程序主体

entry:
		MOV		AX,0			; 初始化寄存器
		MOV		SS,AX
		MOV		SP,0x7c00
		MOV		DS,AX
; 读磁盘
		MOV 	AX,0x0820
		MOV 	ES,AX
		MOV 	CH,0 			; 柱面0
		MOV 	DH,0 			; 磁头0
		MOV 	CL,2 			; 扇区2
readloop:
		MOV 	SI,0 			; 记录失败次数的寄存器
retry:
		MOV 	AH,0x02 		; AH=0x02 : 读盘
		MOV 	AL,1 			; 1个扇区
		MOV 	BX,0
		MOV 	DL,0x00 		; A驱动器
		INT 	0x13 			; 调用磁盘BIOS
		JNC		next			; 没出错就跳到fin
		ADD		SI,1 			; SI+1
		CMP		SI,5 			; 比较SI和5
		JAE		error			; SI>=5时，跳转到error
		MOV 	AH,0x00
		MOV 	DL,0x00 		; A驱动器
		INT 	0x13 			; 重置驱动器
		JMP 	retry
next:
		MOV		AX,ES			; ƒAƒhƒŒƒX‚ð0x200i‚ß‚é
		ADD		AX,0x0020
		MOV		ES,AX			; ADD ES,0x020 ‚Æ‚¢‚¤–½—ß‚ª‚È‚¢‚Ì‚Å‚±‚¤‚µ‚Ä‚¢‚é
		ADD		CL,1			; CL‚É1‚ð‘«‚·
		CMP		CL,18			; CL‚Æ18‚ð”äŠr
		JBE		readloop		; CL <= 18 ‚¾‚Á‚½‚çreadloop‚Ö
		MOV		CL,1
		ADD		DH,1
		CMP		DH,2
		JB		readloop		; DH < 2 ‚¾‚Á‚½‚çreadloop‚Ö
		MOV		DH,0
		ADD		CH,1
		CMP		CH,CYLS
		JB		readloop		; CH < CYLS ‚¾‚Á‚½‚çreadloop‚Ö

		MOV		[0x0ff0],CH
		JMP 	0xc200

error:
		MOV		SI,msg
putloop:
		MOV		AL,[SI]
		ADD		SI,1			; 把SI地址的1个字节的内容读入AL中
		CMP		AL,0
		JE		fin
		MOV		AH,0x0e			; 显示一个文字
		MOV		BX,15			; 指定字符颜色
		INT		0x10			; 调用显卡BIOS,INT：interrupt，中断命令
		JMP		putloop
fin:
		HLT						; 让CPU停止，等待指令,halt简称
		JMP		fin				; 无限循环

msg:
		DB		0x0a, 0x0a		; 2个换行
		DB		"load error"
		DB		0x0a			; 换行
		DB		0

		RESB	0x7dfe-$		; 填写0x00,直到0x001fe,总计378个

		DB		0x55, 0xaa
