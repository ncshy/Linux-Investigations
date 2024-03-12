	.file	"volatile.c"
	.text
.Ltext0:
	.globl	main
	.type	main, @function
main:
.LFB6:
	.file 1 "volatile.c"
	.loc 1 4 12
	.cfi_startproc
	endbr64
	pushq	%rbp
	.cfi_def_cfa_offset 16
	.cfi_offset 6, -16
	movq	%rsp, %rbp
	.cfi_def_cfa_register 6
	.loc 1 6 18
	movl	$10, -12(%rbp)
	.loc 1 7 9
	movl	$0, -8(%rbp)
.LBB2:
	.loc 1 9 13
	movl	$0, -4(%rbp)
	.loc 1 9 5
	jmp	.L2
.L3:
	.loc 1 10 11 discriminator 3
	movl	-4(%rbp), %eax
	movl	%eax, -12(%rbp)
	.loc 1 11 9 discriminator 3
	.loc 1 12 9 discriminator 3
	movl	-12(%rbp), %eax
	.loc 1 12 13 discriminator 3
	addl	%eax, -8(%rbp)
	.loc 1 9 29 discriminator 3
	addl	$1, -4(%rbp)
.L2:
	.loc 1 9 5 discriminator 1
	cmpl	$9, -4(%rbp)
	jle	.L3
.LBE2:
	movl	$0, %eax
	.loc 1 15 1
	popq	%rbp
	.cfi_def_cfa 7, 8
	ret
	.cfi_endproc
.LFE6:
	.size	main, .-main
.Letext0:
	.file 2 "/usr/lib/gcc/x86_64-linux-gnu/9/include/stddef.h"
	.file 3 "/usr/include/x86_64-linux-gnu/bits/types.h"
	.file 4 "/usr/include/x86_64-linux-gnu/bits/types/struct_FILE.h"
	.file 5 "/usr/include/x86_64-linux-gnu/bits/types/FILE.h"
	.file 6 "/usr/include/stdio.h"
	.file 7 "/usr/include/x86_64-linux-gnu/bits/sys_errlist.h"
	.section	.debug_info,"",@progbits
.Ldebug_info0:
	.long	0x34c
	.value	0x4
	.long	.Ldebug_abbrev0
	.byte	0x8
	.uleb128 0x1
	.long	.LASF51
	.byte	0xc
	.long	.LASF52
	.long	.LASF53
	.quad	.Ltext0
	.quad	.Letext0-.Ltext0
	.long	.Ldebug_line0
	.uleb128 0x2
	.long	.LASF7
	.byte	0x2
	.byte	0xd1
	.byte	0x17
	.long	0x39
	.uleb128 0x3
	.byte	0x8
	.byte	0x7
	.long	.LASF0
	.uleb128 0x3
	.byte	0x4
	.byte	0x7
	.long	.LASF1
	.uleb128 0x4
	.byte	0x8
	.uleb128 0x3
	.byte	0x1
	.byte	0x8
	.long	.LASF2
	.uleb128 0x3
	.byte	0x2
	.byte	0x7
	.long	.LASF3
	.uleb128 0x3
	.byte	0x1
	.byte	0x6
	.long	.LASF4
	.uleb128 0x3
	.byte	0x2
	.byte	0x5
	.long	.LASF5
	.uleb128 0x5
	.byte	0x4
	.byte	0x5
	.string	"int"
	.uleb128 0x6
	.long	0x65
	.uleb128 0x3
	.byte	0x8
	.byte	0x5
	.long	.LASF6
	.uleb128 0x2
	.long	.LASF8
	.byte	0x3
	.byte	0x98
	.byte	0x19
	.long	0x71
	.uleb128 0x2
	.long	.LASF9
	.byte	0x3
	.byte	0x99
	.byte	0x1b
	.long	0x71
	.uleb128 0x7
	.byte	0x8
	.long	0x96
	.uleb128 0x3
	.byte	0x1
	.byte	0x6
	.long	.LASF10
	.uleb128 0x8
	.long	0x96
	.uleb128 0x9
	.long	.LASF54
	.byte	0xd8
	.byte	0x4
	.byte	0x31
	.byte	0x8
	.long	0x229
	.uleb128 0xa
	.long	.LASF11
	.byte	0x4
	.byte	0x33
	.byte	0x7
	.long	0x65
	.byte	0
	.uleb128 0xa
	.long	.LASF12
	.byte	0x4
	.byte	0x36
	.byte	0x9
	.long	0x90
	.byte	0x8
	.uleb128 0xa
	.long	.LASF13
	.byte	0x4
	.byte	0x37
	.byte	0x9
	.long	0x90
	.byte	0x10
	.uleb128 0xa
	.long	.LASF14
	.byte	0x4
	.byte	0x38
	.byte	0x9
	.long	0x90
	.byte	0x18
	.uleb128 0xa
	.long	.LASF15
	.byte	0x4
	.byte	0x39
	.byte	0x9
	.long	0x90
	.byte	0x20
	.uleb128 0xa
	.long	.LASF16
	.byte	0x4
	.byte	0x3a
	.byte	0x9
	.long	0x90
	.byte	0x28
	.uleb128 0xa
	.long	.LASF17
	.byte	0x4
	.byte	0x3b
	.byte	0x9
	.long	0x90
	.byte	0x30
	.uleb128 0xa
	.long	.LASF18
	.byte	0x4
	.byte	0x3c
	.byte	0x9
	.long	0x90
	.byte	0x38
	.uleb128 0xa
	.long	.LASF19
	.byte	0x4
	.byte	0x3d
	.byte	0x9
	.long	0x90
	.byte	0x40
	.uleb128 0xa
	.long	.LASF20
	.byte	0x4
	.byte	0x40
	.byte	0x9
	.long	0x90
	.byte	0x48
	.uleb128 0xa
	.long	.LASF21
	.byte	0x4
	.byte	0x41
	.byte	0x9
	.long	0x90
	.byte	0x50
	.uleb128 0xa
	.long	.LASF22
	.byte	0x4
	.byte	0x42
	.byte	0x9
	.long	0x90
	.byte	0x58
	.uleb128 0xa
	.long	.LASF23
	.byte	0x4
	.byte	0x44
	.byte	0x16
	.long	0x242
	.byte	0x60
	.uleb128 0xa
	.long	.LASF24
	.byte	0x4
	.byte	0x46
	.byte	0x14
	.long	0x248
	.byte	0x68
	.uleb128 0xa
	.long	.LASF25
	.byte	0x4
	.byte	0x48
	.byte	0x7
	.long	0x65
	.byte	0x70
	.uleb128 0xa
	.long	.LASF26
	.byte	0x4
	.byte	0x49
	.byte	0x7
	.long	0x65
	.byte	0x74
	.uleb128 0xa
	.long	.LASF27
	.byte	0x4
	.byte	0x4a
	.byte	0xb
	.long	0x78
	.byte	0x78
	.uleb128 0xa
	.long	.LASF28
	.byte	0x4
	.byte	0x4d
	.byte	0x12
	.long	0x50
	.byte	0x80
	.uleb128 0xa
	.long	.LASF29
	.byte	0x4
	.byte	0x4e
	.byte	0xf
	.long	0x57
	.byte	0x82
	.uleb128 0xa
	.long	.LASF30
	.byte	0x4
	.byte	0x4f
	.byte	0x8
	.long	0x24e
	.byte	0x83
	.uleb128 0xa
	.long	.LASF31
	.byte	0x4
	.byte	0x51
	.byte	0xf
	.long	0x25e
	.byte	0x88
	.uleb128 0xa
	.long	.LASF32
	.byte	0x4
	.byte	0x59
	.byte	0xd
	.long	0x84
	.byte	0x90
	.uleb128 0xa
	.long	.LASF33
	.byte	0x4
	.byte	0x5b
	.byte	0x17
	.long	0x269
	.byte	0x98
	.uleb128 0xa
	.long	.LASF34
	.byte	0x4
	.byte	0x5c
	.byte	0x19
	.long	0x274
	.byte	0xa0
	.uleb128 0xa
	.long	.LASF35
	.byte	0x4
	.byte	0x5d
	.byte	0x14
	.long	0x248
	.byte	0xa8
	.uleb128 0xa
	.long	.LASF36
	.byte	0x4
	.byte	0x5e
	.byte	0x9
	.long	0x47
	.byte	0xb0
	.uleb128 0xa
	.long	.LASF37
	.byte	0x4
	.byte	0x5f
	.byte	0xa
	.long	0x2d
	.byte	0xb8
	.uleb128 0xa
	.long	.LASF38
	.byte	0x4
	.byte	0x60
	.byte	0x7
	.long	0x65
	.byte	0xc0
	.uleb128 0xa
	.long	.LASF39
	.byte	0x4
	.byte	0x62
	.byte	0x8
	.long	0x27a
	.byte	0xc4
	.byte	0
	.uleb128 0x2
	.long	.LASF40
	.byte	0x5
	.byte	0x7
	.byte	0x19
	.long	0xa2
	.uleb128 0xb
	.long	.LASF55
	.byte	0x4
	.byte	0x2b
	.byte	0xe
	.uleb128 0xc
	.long	.LASF41
	.uleb128 0x7
	.byte	0x8
	.long	0x23d
	.uleb128 0x7
	.byte	0x8
	.long	0xa2
	.uleb128 0xd
	.long	0x96
	.long	0x25e
	.uleb128 0xe
	.long	0x39
	.byte	0
	.byte	0
	.uleb128 0x7
	.byte	0x8
	.long	0x235
	.uleb128 0xc
	.long	.LASF42
	.uleb128 0x7
	.byte	0x8
	.long	0x264
	.uleb128 0xc
	.long	.LASF43
	.uleb128 0x7
	.byte	0x8
	.long	0x26f
	.uleb128 0xd
	.long	0x96
	.long	0x28a
	.uleb128 0xe
	.long	0x39
	.byte	0x13
	.byte	0
	.uleb128 0xf
	.long	.LASF44
	.byte	0x6
	.byte	0x89
	.byte	0xe
	.long	0x296
	.uleb128 0x7
	.byte	0x8
	.long	0x229
	.uleb128 0xf
	.long	.LASF45
	.byte	0x6
	.byte	0x8a
	.byte	0xe
	.long	0x296
	.uleb128 0xf
	.long	.LASF46
	.byte	0x6
	.byte	0x8b
	.byte	0xe
	.long	0x296
	.uleb128 0xf
	.long	.LASF47
	.byte	0x7
	.byte	0x1a
	.byte	0xc
	.long	0x65
	.uleb128 0xd
	.long	0x2d6
	.long	0x2cb
	.uleb128 0x10
	.byte	0
	.uleb128 0x8
	.long	0x2c0
	.uleb128 0x7
	.byte	0x8
	.long	0x9d
	.uleb128 0x8
	.long	0x2d0
	.uleb128 0xf
	.long	.LASF48
	.byte	0x7
	.byte	0x1b
	.byte	0x1a
	.long	0x2cb
	.uleb128 0x3
	.byte	0x8
	.byte	0x5
	.long	.LASF49
	.uleb128 0x3
	.byte	0x8
	.byte	0x7
	.long	.LASF50
	.uleb128 0x11
	.long	.LASF56
	.byte	0x1
	.byte	0x4
	.byte	0x5
	.long	0x65
	.quad	.LFB6
	.quad	.LFE6-.LFB6
	.uleb128 0x1
	.byte	0x9c
	.uleb128 0x12
	.string	"a"
	.byte	0x1
	.byte	0x6
	.byte	0x12
	.long	0x6c
	.uleb128 0x2
	.byte	0x91
	.sleb128 -28
	.uleb128 0x12
	.string	"sum"
	.byte	0x1
	.byte	0x7
	.byte	0x9
	.long	0x65
	.uleb128 0x2
	.byte	0x91
	.sleb128 -24
	.uleb128 0x13
	.quad	.LBB2
	.quad	.LBE2-.LBB2
	.uleb128 0x12
	.string	"i"
	.byte	0x1
	.byte	0x9
	.byte	0xd
	.long	0x65
	.uleb128 0x2
	.byte	0x91
	.sleb128 -20
	.byte	0
	.byte	0
	.byte	0
	.section	.debug_abbrev,"",@progbits
.Ldebug_abbrev0:
	.uleb128 0x1
	.uleb128 0x11
	.byte	0x1
	.uleb128 0x25
	.uleb128 0xe
	.uleb128 0x13
	.uleb128 0xb
	.uleb128 0x3
	.uleb128 0xe
	.uleb128 0x1b
	.uleb128 0xe
	.uleb128 0x11
	.uleb128 0x1
	.uleb128 0x12
	.uleb128 0x7
	.uleb128 0x10
	.uleb128 0x17
	.byte	0
	.byte	0
	.uleb128 0x2
	.uleb128 0x16
	.byte	0
	.uleb128 0x3
	.uleb128 0xe
	.uleb128 0x3a
	.uleb128 0xb
	.uleb128 0x3b
	.uleb128 0xb
	.uleb128 0x39
	.uleb128 0xb
	.uleb128 0x49
	.uleb128 0x13
	.byte	0
	.byte	0
	.uleb128 0x3
	.uleb128 0x24
	.byte	0
	.uleb128 0xb
	.uleb128 0xb
	.uleb128 0x3e
	.uleb128 0xb
	.uleb128 0x3
	.uleb128 0xe
	.byte	0
	.byte	0
	.uleb128 0x4
	.uleb128 0xf
	.byte	0
	.uleb128 0xb
	.uleb128 0xb
	.byte	0
	.byte	0
	.uleb128 0x5
	.uleb128 0x24
	.byte	0
	.uleb128 0xb
	.uleb128 0xb
	.uleb128 0x3e
	.uleb128 0xb
	.uleb128 0x3
	.uleb128 0x8
	.byte	0
	.byte	0
	.uleb128 0x6
	.uleb128 0x35
	.byte	0
	.uleb128 0x49
	.uleb128 0x13
	.byte	0
	.byte	0
	.uleb128 0x7
	.uleb128 0xf
	.byte	0
	.uleb128 0xb
	.uleb128 0xb
	.uleb128 0x49
	.uleb128 0x13
	.byte	0
	.byte	0
	.uleb128 0x8
	.uleb128 0x26
	.byte	0
	.uleb128 0x49
	.uleb128 0x13
	.byte	0
	.byte	0
	.uleb128 0x9
	.uleb128 0x13
	.byte	0x1
	.uleb128 0x3
	.uleb128 0xe
	.uleb128 0xb
	.uleb128 0xb
	.uleb128 0x3a
	.uleb128 0xb
	.uleb128 0x3b
	.uleb128 0xb
	.uleb128 0x39
	.uleb128 0xb
	.uleb128 0x1
	.uleb128 0x13
	.byte	0
	.byte	0
	.uleb128 0xa
	.uleb128 0xd
	.byte	0
	.uleb128 0x3
	.uleb128 0xe
	.uleb128 0x3a
	.uleb128 0xb
	.uleb128 0x3b
	.uleb128 0xb
	.uleb128 0x39
	.uleb128 0xb
	.uleb128 0x49
	.uleb128 0x13
	.uleb128 0x38
	.uleb128 0xb
	.byte	0
	.byte	0
	.uleb128 0xb
	.uleb128 0x16
	.byte	0
	.uleb128 0x3
	.uleb128 0xe
	.uleb128 0x3a
	.uleb128 0xb
	.uleb128 0x3b
	.uleb128 0xb
	.uleb128 0x39
	.uleb128 0xb
	.byte	0
	.byte	0
	.uleb128 0xc
	.uleb128 0x13
	.byte	0
	.uleb128 0x3
	.uleb128 0xe
	.uleb128 0x3c
	.uleb128 0x19
	.byte	0
	.byte	0
	.uleb128 0xd
	.uleb128 0x1
	.byte	0x1
	.uleb128 0x49
	.uleb128 0x13
	.uleb128 0x1
	.uleb128 0x13
	.byte	0
	.byte	0
	.uleb128 0xe
	.uleb128 0x21
	.byte	0
	.uleb128 0x49
	.uleb128 0x13
	.uleb128 0x2f
	.uleb128 0xb
	.byte	0
	.byte	0
	.uleb128 0xf
	.uleb128 0x34
	.byte	0
	.uleb128 0x3
	.uleb128 0xe
	.uleb128 0x3a
	.uleb128 0xb
	.uleb128 0x3b
	.uleb128 0xb
	.uleb128 0x39
	.uleb128 0xb
	.uleb128 0x49
	.uleb128 0x13
	.uleb128 0x3f
	.uleb128 0x19
	.uleb128 0x3c
	.uleb128 0x19
	.byte	0
	.byte	0
	.uleb128 0x10
	.uleb128 0x21
	.byte	0
	.byte	0
	.byte	0
	.uleb128 0x11
	.uleb128 0x2e
	.byte	0x1
	.uleb128 0x3f
	.uleb128 0x19
	.uleb128 0x3
	.uleb128 0xe
	.uleb128 0x3a
	.uleb128 0xb
	.uleb128 0x3b
	.uleb128 0xb
	.uleb128 0x39
	.uleb128 0xb
	.uleb128 0x49
	.uleb128 0x13
	.uleb128 0x11
	.uleb128 0x1
	.uleb128 0x12
	.uleb128 0x7
	.uleb128 0x40
	.uleb128 0x18
	.uleb128 0x2117
	.uleb128 0x19
	.byte	0
	.byte	0
	.uleb128 0x12
	.uleb128 0x34
	.byte	0
	.uleb128 0x3
	.uleb128 0x8
	.uleb128 0x3a
	.uleb128 0xb
	.uleb128 0x3b
	.uleb128 0xb
	.uleb128 0x39
	.uleb128 0xb
	.uleb128 0x49
	.uleb128 0x13
	.uleb128 0x2
	.uleb128 0x18
	.byte	0
	.byte	0
	.uleb128 0x13
	.uleb128 0xb
	.byte	0x1
	.uleb128 0x11
	.uleb128 0x1
	.uleb128 0x12
	.uleb128 0x7
	.byte	0
	.byte	0
	.byte	0
	.section	.debug_aranges,"",@progbits
	.long	0x2c
	.value	0x2
	.long	.Ldebug_info0
	.byte	0x8
	.byte	0
	.value	0
	.value	0
	.quad	.Ltext0
	.quad	.Letext0-.Ltext0
	.quad	0
	.quad	0
	.section	.debug_line,"",@progbits
.Ldebug_line0:
	.section	.debug_str,"MS",@progbits,1
.LASF9:
	.string	"__off64_t"
.LASF13:
	.string	"_IO_read_end"
.LASF7:
	.string	"size_t"
.LASF54:
	.string	"_IO_FILE"
.LASF46:
	.string	"stderr"
.LASF15:
	.string	"_IO_write_base"
.LASF19:
	.string	"_IO_buf_end"
.LASF12:
	.string	"_IO_read_ptr"
.LASF37:
	.string	"__pad5"
.LASF1:
	.string	"unsigned int"
.LASF32:
	.string	"_offset"
.LASF38:
	.string	"_mode"
.LASF48:
	.string	"sys_errlist"
.LASF24:
	.string	"_chain"
.LASF20:
	.string	"_IO_save_base"
.LASF2:
	.string	"unsigned char"
.LASF36:
	.string	"_freeres_buf"
.LASF47:
	.string	"sys_nerr"
.LASF0:
	.string	"long unsigned int"
.LASF3:
	.string	"short unsigned int"
.LASF44:
	.string	"stdin"
.LASF22:
	.string	"_IO_save_end"
.LASF55:
	.string	"_IO_lock_t"
.LASF23:
	.string	"_markers"
.LASF56:
	.string	"main"
.LASF40:
	.string	"FILE"
.LASF26:
	.string	"_flags2"
.LASF52:
	.string	"volatile.c"
.LASF27:
	.string	"_old_offset"
.LASF31:
	.string	"_lock"
.LASF51:
	.string	"GNU C17 9.3.0 -mtune=generic -march=x86-64 -g -fasynchronous-unwind-tables -fstack-protector-strong -fstack-clash-protection -fcf-protection"
.LASF41:
	.string	"_IO_marker"
.LASF28:
	.string	"_cur_column"
.LASF50:
	.string	"long long unsigned int"
.LASF42:
	.string	"_IO_codecvt"
.LASF25:
	.string	"_fileno"
.LASF18:
	.string	"_IO_buf_base"
.LASF29:
	.string	"_vtable_offset"
.LASF33:
	.string	"_codecvt"
.LASF35:
	.string	"_freeres_list"
.LASF8:
	.string	"__off_t"
.LASF39:
	.string	"_unused2"
.LASF49:
	.string	"long long int"
.LASF45:
	.string	"stdout"
.LASF10:
	.string	"char"
.LASF53:
	.string	"/home/nishanth/git_ncshy/Linux-Investigations/investigate_volatile"
.LASF17:
	.string	"_IO_write_end"
.LASF5:
	.string	"short int"
.LASF21:
	.string	"_IO_backup_base"
.LASF11:
	.string	"_flags"
.LASF34:
	.string	"_wide_data"
.LASF6:
	.string	"long int"
.LASF16:
	.string	"_IO_write_ptr"
.LASF43:
	.string	"_IO_wide_data"
.LASF4:
	.string	"signed char"
.LASF14:
	.string	"_IO_read_base"
.LASF30:
	.string	"_shortbuf"
	.ident	"GCC: (Ubuntu 9.3.0-10ubuntu2) 9.3.0"
	.section	.note.GNU-stack,"",@progbits
	.section	.note.gnu.property,"a"
	.align 8
	.long	 1f - 0f
	.long	 4f - 1f
	.long	 5
0:
	.string	 "GNU"
1:
	.align 8
	.long	 0xc0000002
	.long	 3f - 2f
2:
	.long	 0x3
3:
	.align 8
4:
