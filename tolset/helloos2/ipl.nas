; hello-os
; TAB=4

		ORG		0x7c00			; 指明程序的装载地址

; 标准FAT12格式软盘专用代码

		JMP		entry
		DB		0x90
		DB		"HELLOIPL"		; 启动区的名称
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
		DB		"HELLO-OS   "	; 磁盘的名称
		DB		"FAT12   "		; 磁盘格式名称
		RESB	18				; 空出18个字节

; 程序主体

entry:
		MOV		AX,0			; 初始化寄存器，MOV即为MOVE，类似COPY的功能，虽然不太一样
		MOV		SS,AX
		MOV		SP,0x7c00
		MOV		DS,AX
		MOV		ES,AX

		MOV		SI,msg
putloop:
		MOV		AL,[SI]			; 把SI地址的1个字节的内容读入AL中
		ADD		SI,1			; 给SI加1
		CMP		Al,0 			; CMP：compare，相等
		JE		fin				; 相等的话跳到fin
		MOV		AH,0x0e			; 显示一个文字
		MOV		BX,15			; 指定字符颜色
		INT		0x10			; 调用显卡BIOS,INT：interrupt，中断命令
		JMP		putloop
fin:
		HLT						; 让CPU停止，等待指令,halt简称
		JMP		fin				; 无限循环

; 信息显示部分
msg:

		DB		0x0a, 0x0a		; 2个换行
		DB		"hello, world"
		DB		0x0a			; 换行
		DB		0

		RESB	0x1fe-$			; 填写0x00,直到0x001fe,总计378个

		DB		0x55, 0xaa
