## Importance of endianness when dealing with bitfields

According to Kernighan and Ritchie, bitfields are implementation dependent. They may be ordered from left to right, or right to left and are meant to be used safely only within a system to avoid portability issues. <br>

We see an example of where this portability issue arises when used across systems, in the Linux kernel network stack. The definition for the struct iphdr is shown below, defined in *include/uapi/linux/ip.h/*:
```C

struct iphdr {
#if defined(__LITTLE_ENDIAN_BITFIELD)
        __u8    ihl:4,
                version:4;
#elif defined (__BIG_ENDIAN_BITFIELD)
        __u8    version:4,
                ihl:4;
#else
#error  "Please fix <asm/byteorder.h>"
#endif
        __u8    tos;
        __be16  tot_len;
        __be16  id;
        __be16  frag_off;
        __u8    ttl;
        __u8    protocol;
        __sum16 check;
        __struct_group(/* no tag */, addrs, /* no attrs */,
                __be32  saddr;
                __be32  daddr;
        );
        /*The options start here. */
};

```
The first byte is split into 2 bitfields. According to IP header spec, the 'version' field comes first followed by the 'ihl' field. <br>
The iphdr definition in the Linux kernel however uses bitfields for this 1st byte, and as a result, portability needs to be taken care of. For a little endian system, the bitfields within the byte need to be flipped, with 'ihl' coming first followed by 'version'. <br>

Below is some simple code to show how endianness affects bitfield representation. The program is run on an x86 Little Endian system.
```C
struct dummy {
        uint8_t version:4;
        uint8_t ihl:4;
        uint8_t tos;
};

```
The above structure defines the 1st 2 bytes of the IP header. The fields are initialized below and the 2 bytes are printed out as shown below.  

```C
int main()
{
        struct dummy dmy;
        uint8_t *u8ptr;
        int length = sizeof(struct dummy);
        dmy.version = 4;
        dmy.ihl = 5;
        dmy.tos = 1;
        
	u8ptr = (uint8_t *)&dmy;
        for (int i = 0; i < length; i++) {
                printf("%02x ", u8ptr[i]);
        }
        printf("\n");
	return 0;
}
```
The output of the program is below: 
```
54 01
```
The above shows that for the little endian system, the bitfields are flipped from what was intended. <br>

In my opinion, a better implementation for the Kernel network stack would have been to use bit shifting to handle writing and reading the field, as shown below: <br>
```C
#define IPVERSION_SHIFT 4

struct dummy2 {
        uint8_t version_ihl;
        uint8_t tos;
};

int main()
{
        struct dummy2 dmy2;
        dmy2.version_ihl = 5;
        dmy2.version_ihl |= (4 << IPVERSION_SHIFT);
        dmy2.tos = 1;
        u8ptr = (uint8_t *)&dmy2;
        for (int i = 0; i < length; i++) {
                printf("%02x ", u8ptr[i]);
        }
        printf("\n");
	return 0;
}

```
The above avoids portability issues as it avoids bitfields, however it tradesoff the convenience of accessing the fields directly using the structure 'dmy.version' and 'dmy.ihl' etc. <br>
The output of the above code is shown here:
```
45 01
```

