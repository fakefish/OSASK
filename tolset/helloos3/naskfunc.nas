; naskfunc
[FORMAT "WCOFF"]					; 制作目标文件的模式
[BITS 32]							; 制作32位模式用的机械语言


[FILE "naskfunc.nas"]				; 源文件名信息

		GLOBAL _io_hlt				; 程序中包含的函数名

[SECTION .text]

;以下是实际的函数

_io_hlt:							; void _io_hlt(void)
		HLT
		RET