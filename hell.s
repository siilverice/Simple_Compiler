	.global main

	.text
main:
	push	%rbp
	mov	%rsp, %rbp
	sub	$104, %rsp

	xor	%rax, %rax
	cmp	$1, %rax
	push	%rax

	jz	print10
	jmp	print16
printing:

	mov	$60, %rsi

	call	printf

	pop	%rax
	leave
	ret
	jmp	done
print10:
	mov $format10, %rdi
	jmp printing

print16:
	mov $format16, %rdi
	jmp printing

done:
	add	$104, %rsp
	mov	$0, %rax
	leave
	ret

string:
	.asciz	"0"
format10:
	.asciz	"[%d]\n"
format16:
	.asciz	"[%x]\n"
