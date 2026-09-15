option casemap:none

STD_OUTPUT_HANDLE equ -11

extern GetStdHandle:proc
extern WriteConsoleA:proc
extern ExitProcess:proc

.data
msg db "Hello, world!", 13, 10
msgLen equ $ - msg

.code
main proc
  ; Reserve stack space required by the Windows x64 calling convention.
  sub rsp, 40

  ; HANDLE GetStdHandle(STD_OUTPUT_HANDLE)
  mov ecx, STD_OUTPUT_HANDLE
  call GetStdHandle

  ; WriteConsoleA(
  ;   handle,
  ;   message,
  ;   messageLength,
  ;   NULL,
  ;   NULL
  ; )
  mov rcx, rax
  lea rdx, msg
  mov r8d, msgLen
  xor r9d, r9d
  mov qword ptr [rsp + 32], 0
  call WriteConsoleA

  ; ExitProcess(0)
  xor ecx, ecx
  call ExitProcess
main endp

end
