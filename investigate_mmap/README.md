# Investigation of mmap function

Memory mapping in this example, is meant to map a file in disk onto a process's memory space.
Once this mapping is successful, an address pointing to the beginning of this memory map is given to the user space process.
It can be treated as an array of bytes and can be read to or written to. 

The main command in user-space is:  
mmap_addr = mmap(NULL, 20, PROT_READ|PROT_WRITE, MAP_SHARED, fd, 0);

A brief notes on the arguments, <br>
**NULL** - Asks the kernel to give us an appropriate memory address. <br>
**20** - Map 20 bytes in total from the file beginning. <br>
**PROT_*** - Allow read/write permissions <br>
**MAP_SHARED** - Any writes to the memory, are visible to everyone sharing the same memory. More importantly, writes are written back to file. <br>
**MAP_PRIVATE** - Any writes to the memory disconnect it from the actual file and no changes are reflected. <br>
**fd** - file descriptor of the file that needs to be mapped. <br>
**0** - Offset from the beginning of the file. <br>

There is a textfile.txt, that is the file on the disk. It contains
```
$ cat textfile.txt
Hello World!
```
After the successful map of the file, mmap_address contains the address that corresponds to the beginning of the file.
Thereafter, 
```
mmap_address[0] = 'Y';
```
is used to alter the first byte. This change will be reflected on the actual file. This can be checked,

```
$ cat textfile.txt
Yello World!
```
If MAP_PRIVATE was specified instead in mmap arguments, then the file would still show "Hello World!" even after the program completes.

For files on disk, the core mmap is supported by the filesystem support code in the kernel. Shared libraries(ELF shared object) have their segments mapped onto process memory space using mmap. <br>
It's not only files that can be mapped, even HW device memory can be mapped. The core mmap logic will be provided by the Device Driver for that device.
