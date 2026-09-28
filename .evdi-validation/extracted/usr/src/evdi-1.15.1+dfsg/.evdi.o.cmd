savedcmd_evdi.o := x86_64-linux-gnu-ld -m elf_x86_64 -z noexecstack --no-warn-rwx-segments   -r -o evdi.o @evdi.mod  ; /usr/src/linux-headers-7.0.12+deb13-amd64/tools/objtool/objtool --hacks=jump_label --hacks=noinstr --hacks=skylake --ibt --orc --retpoline --rethunk --sls --static-call --uaccess --prefix=16  --link  --module evdi.o

evdi.o: $(wildcard /usr/src/linux-headers-7.0.12+deb13-amd64/tools/objtool/objtool)
