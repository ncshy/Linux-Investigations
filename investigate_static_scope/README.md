# Linux investigation of static keyword scope

I was wondering if the static keyword within a function had it's scope defined by program layout. <br>
```
0000000000001149 <add_static>:
    1149:	f3 0f 1e fa          	endbr64 
    114d:	55                   	push   %rbp
    114e:	48 89 e5             	mov    %rsp,%rbp
    1151:	8b 05 bd 2e 00 00    	mov    0x2ebd(%rip),%eax        # 4014 <sum.2833>
    1157:	83 f8 14             	cmp    $0x14,%eax                                                   if(sum > 20)
    115a:	7e 08                	jle    1164 <add_static+0x1b>                                          
    115c:	8b 05 b2 2e 00 00    	mov    0x2eb2(%rip),%eax        # 4014 <sum.2833>
    1162:	eb 2a                	jmp    118e <add_static+0x45>                   
    1164:	8b 15 aa 2e 00 00    	mov    0x2eaa(%rip),%edx        # 4014 <sum.2833>                   sum = sum + a;
    116a:	8b 05 a0 2e 00 00    	mov    0x2ea0(%rip),%eax        # 4010 <a>
    1170:	01 d0                	add    %edx,%eax
    1172:	89 05 9c 2e 00 00    	mov    %eax,0x2e9c(%rip)        # 4014 <sum.2833>
    1178:	b8 00 00 00 00       	mov    $0x0,%eax
    117d:	e8 c7 ff ff ff       	callq  1149 <add_static>                                            sum = add_static();
    1182:	89 05 8c 2e 00 00    	mov    %eax,0x2e8c(%rip)        # 4014 <sum.2833>
    1188:	8b 05 86 2e 00 00    	mov    0x2e86(%rip),%eax        # 4014 <sum.2833>
    118e:	5d                   	pop    %rbp                                                          return sum;
    118f:	c3                   	retq   


Disassembly of section .data:

0000000000004010 <a>:
    4010:	05 00 00 00        	add    $0xa000000,%eax

0000000000004014 <sum.2833>:
    4014:	0a 00                	or     (%rax),%al

```


