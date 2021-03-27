;***********************************************
;程序名稱: Base64_Encoder
;作者: xiao_laba@yahoo.com.cn
;日期: 2010-05-13
;出處: xiao_laba@yahoo.com.cn
;如欲轉載, 請保持本程序的完整, 並注明出處
;***********************************************
; 2010-05-13
; Base64 encoder
;***********************************************

.386
.model flat, stdcall
option casemap:none

include \masm32\include\windows.inc
include \masm32\include\kernel32.inc
include \masm32\include\user32.inc
include \masm32\include\comdlg32.inc
include \masm32\include\wsock32.inc
include \masm32\include\masm32.inc
includelib \masm32\lib\kernel32.lib
includelib \masm32\lib\user32.lib
includelib \masm32\lib\comdlg32.lib
includelib \masm32\lib\wsock32.lib
includelib \masm32\lib\masm32.lib

WndProc	       proto :DWORD, :DWORD, :DWORD, :DWORD
Base64Encode   proto :DWORD, :DWORD, :DWORD


.const
IDI_XIAO		equ 1
IDC_BUTTON_ENCODE	equ 3000
IDC_EDIT_USERNAME	equ 3002
IDC_EDIT_PASSWORD	equ 3003
IDC_EDIT_ENCODED_USER	equ 3004
IDC_EDIT_ENCODED_PWD	equ 3005
MAXNUM			equ 2048
MAXFILESIZE		equ 87380


.data

;下面是為了方便調試，預設的各項參數
szUSER_NAME	db "正文帳號 - 小你個喇叭", 0   ;正文 EMAIL 帳號
szPASSWORD	db "正文密碼 - 小你個喇叭", 0   ;正文密碼
szUSER_NAME_64	db "Base64 編碼後的帳號", 0   	;BASE64 EMAIL 帳號 
szPASSWORD_64	db "Base64 編碼後的密碼", 0   	;BASE64密碼
szDlgName	db "xiao_dialog", 0

;Base64 -> ASCII mapping table
base64_table	db "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
		db "abcdefghijklmnopqrstuvwxyz"
		db "0123456789+/="

.data?
hInstance	dd	?
szBuffer	db	MAXNUM	dup(?)
szBuf1		db	MAXNUM	dup(?)


.code
main:
	invoke GetModuleHandle, NULL
	mov hInstance, eax
	invoke DialogBoxParam, hInstance, offset szDlgName, 0, WndProc, 0
	invoke ExitProcess, eax

WndProc proc hWnd:HWND, uMsg:UINT, wParam:WPARAM, lParam:LPARAM
	LOCAL hFile: HANDLE
	LOCAL hMapFile: HANDLE
	LOCAL dwFileSize: DWORD
	LOCAL pMemory: DWORD
	LOCAL pContent: DWORD
	LOCAL pFileContent: DWORD

	.if uMsg == WM_CLOSE
		invoke EndDialog, hWnd, 0

	.elseif	uMsg == WM_INITDIALOG
		invoke LoadIcon, hInstance, IDI_XIAO
		invoke SendMessage, hWnd, WM_SETICON, ICON_SMALL, eax

		;下面是為了方便調試，填入預設的各項參數：
		invoke SetDlgItemText, hWnd, IDC_EDIT_USERNAME, addr szUSER_NAME
		invoke SetDlgItemText, hWnd, IDC_EDIT_PASSWORD, addr szPASSWORD
		invoke SetDlgItemText, hWnd, IDC_EDIT_ENCODED_USER, addr szUSER_NAME_64
		invoke SetDlgItemText, hWnd, IDC_EDIT_ENCODED_PWD, addr szPASSWORD_64
		
	.elseif uMsg == WM_COMMAND
		mov eax, wParam
		mov edx, eax
		shr edx, 16
		movzx eax, ax
		.if edx == BN_CLICKED
		  .if eax == IDC_BUTTON_ENCODE
                          
		      ;讀取 USER NAME 的文字 , 做 BASE64 編碼, 
		      invoke GetDlgItemText, hWnd, IDC_EDIT_USERNAME, addr szBuffer, 100
		      invoke Base64Encode, addr szBuffer, addr szBuf1, eax
;                      invoke MessageBox, hWnd, addr szBuffer, addr szDlgName, MB_OK
;                      invoke MessageBox, hWnd, addr szBuf1, addr szDlgName, MB_OK
		      invoke SetDlgItemText, hWnd, IDC_EDIT_ENCODED_USER, addr szBuf1
		      
		      invoke RtlZeroMemory, addr szBuf1, MAXNUM
		      invoke RtlZeroMemory, addr szBuffer, MAXNUM
                      
                      
		      ;讀取 PASS WORD 的文字 , 做 BASE64 編碼, 
		      invoke GetDlgItemText, hWnd, IDC_EDIT_PASSWORD, addr szBuffer, 100
		      invoke Base64Encode, addr szBuffer, addr szBuf1, eax                    
                      invoke SetDlgItemText, hWnd, IDC_EDIT_ENCODED_PWD, addr szBuf1
                      
		      invoke RtlZeroMemory, addr szBuf1, MAXNUM
		      invoke RtlZeroMemory, addr szBuffer, MAXNUM

;		  .elseif eax == IDC_BUTTON_BROWSE
		  .endif

		.endif

	.else
		mov eax, FALSE
		ret
	.endif
	mov eax, TRUE
	ret
WndProc endp





;**********************************************************
;函數功能:進行Base64編碼
;入口參數:
;	source	    = 傳入的字符串
;	sourcelen   = 傳入的字符串的長度
;出口參數:
;	destination = 返回的編碼
;**********************************************************
Base64Encode	proc	uses ebx edi esi source:DWORD, destination:DWORD, sourcelen:DWORD
	;LOCAL	sourcelen:DWORD
	;invoke lstrlen, source
	;mov sourcelen, eax

	mov  esi, source
	mov  edi, destination
@@base64loop:
	xor eax, eax
	.if sourcelen == 1
		lodsb		    ;source ptr + 1
		mov ecx, 2	    ;bytes to output = 2
		mov edx, 03D3Dh	    ;padding = 2 byte
		dec sourcelen	    ;length - 1
	.elseif sourcelen == 2      
		lodsw		    ;source ptr + 2
		mov ecx, 3	    ;bytes to output = 3
		mov edx, 03Dh	    ;padding = 1 byte
		sub sourcelen, 2    ;length - 2
	.else                       
		lodsd               ;字串的頭 4 BYTE, 例如 '1234', EAX = '4321'
		mov ecx, 4	    ;bytes to output = 4
		xor edx, edx	    ;padding = 0 byte
		dec esi		    ;source ptr + 3 (+4-1)
		sub sourcelen, 3    ;length - 3 
	.endif                      

	xchg al,ah		    ; EAX = '4312'
	rol  eax, 16		    ; EAX = '1243'
	xchg al,ah                  ; EAX = '1234'

	@@:
	push  eax		    ; 儲存字串
	and   eax, 0FC000000h       ; 取出字串的第一個字符的高位 6 bit
	rol   eax, 6		    ; rotate 6 bit, 移到 AL
	mov   al,  byte ptr [offset base64_table + eax] ; 查base64編碼表, 讀回編碼後的字符
	stosb			    ; 存放編碼後的字符
	pop   eax		    ; 取回字串
	shl   eax, 6		    ; shift left 6 bits, 去掉剛才處理完的6bit
	dec   ecx		    ; 計數, 處理了第幾個 BYTE (共4BYTE)
	jnz   @B		    ; loop,

	cmp   sourcelen, 0
	jnz   @@base64loop	    ;main loop

	mov   eax, edx		    ;add padding and null terminate
	stosd
	
	;; 顯示 based64 的結果
	;;invoke MessageBox, 0, destination, addr szDlgName, MB_OK or MB_ICONHAND

	ret
Base64Encode	endp



;----------------------------
; xiaolaba MAY/13/2010
software_time_delay proc
	push eax
	push ebx
	
	mov ebx, 2
@@DEC_EBX:	
            mov eax, 00fffffffh
@@DEC_EAX:            
            dec eax
            jnz @@DEC_EAX
	dec ebx
	jnz @@DEC_EBX
	
	pop ebx
	pop eax
	ret
software_time_delay	endp


end main
;********************	over	********************
