// set_program.c: output a RISC-V 32 program according to the binary protocol.
// use: set_program asm.s
// The binary protocol
// [1 byte size of program][program binary]
// compute the size of the program and place it at the start of the binary

#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <unistd.h>
#include <fcntl.h>
#include <sys/wait.h>
#include <sys/stat.h>

char outname[1024]; 
int status;
int pid;
int oflag=0;
int fdobj;
int fdfin;
int size;

int main(int argc, char** argv){
	char* argv_as[] = {"/opt/riscv/bin/riscv32-unknown-linux-gnu-as", argv[1], "-o", "imm.o", NULL};
	char* argv_objcopy[] = {"/opt/riscv/bin/riscv32-unknown-linux-gnu-objcopy", "-O", "binary", "imm.o", "imm.bin", NULL};

	if(argc != 2 && argc != 4){
		printf("%s: set_program <asm.s>\n",argv[0]);	
		exit(1);
	}
	if(argc == 4){
		if((strcmp(argv[2], "-o") == 0) && argv[3] != NULL)
			oflag = 1;	
		
	}
	if (oflag==1)
		strcpy(outname, argv[3]);
	else
		strcpy(outname, "a.bin");

	pid = fork();
	if(pid == 0){ /* child */	
		exit(execv("/opt/riscv/bin/riscv32-unknown-linux-gnu-as", argv_as));
	}
	else if(pid > 0){ /* parent */
		wait(&status);
		if(status != 0){
			printf("%s: error assembling the file\n", argv[0]);
			return 1;
		}
		pid = fork();
		if(pid == 0){ /* child */	
			exit(execv("/opt/riscv/bin/riscv32-unknown-linux-gnu-objcopy", argv_objcopy));
		}
		else if(pid > 0){ /* parent */
			wait(&status);
			if(status != 0){
				printf("%s: error copying object file\n", argv[0]);
				return 1;
			}
			fdobj= open("imm.bin", O_RDONLY);

			if(fdobj < 0){
				printf("%s: error opening binary file\n", argv[0]);
				close(fdobj);close(fdfin);
				exit(1);
			}
			struct stat st;
			if(fstat(fdobj,&st) == 0){
				size = st.st_size;	
				if(size > 0xFF){
					printf("%s: size of the prgram exceeds a byte\n",argv[0]);
					close(fdobj);close(fdfin);
				}
			}
			else{
				printf("%s: error fstat\n", argv[0]);
				close(fdobj);close(fdfin);
				exit(1);
			}

			/* Actual file assembling */	
			int fdfin = open(outname, O_RDWR | O_CREAT | O_TRUNC, 0666);
			if(fdfin < 0){
				printf("%s: cannot open %s\n", argv[0], outname);
				close(fdobj);close(fdfin);
				exit(1);
			}
			int sz[1];
			sz[0] = size;
			/* Write the header */
			if(write(fdfin, sz, 1)!=1){
				printf("%s: error writing to %s\n", argv[0], outname);
				close(fdobj);close(fdfin);
				exit(1);
			}
		    /* Copy the program */	
			char buff[1];
			for(int i=0; i < size; i++){
				if(read(fdobj, buff, 1) != 1){
					printf("%s: error reading from imm file\n", argv[0]);
					close(fdobj);close(fdfin);
					exit(1);
				}
				if(write(fdfin, buff, 1) != 1){
					printf("%s: error writing to %s\n", argv[0], outname);
					close(fdobj);close(fdfin);
					exit(1);
				}
			}
			/* Delete immediate files */	
			close(fdobj);close(fdfin);
			remove("imm.o");	
			remove("imm.bin");	
		}
		else{
			printf("%s: fork failed\n",argv[0]);
			return 1;
		}
	}
	else{
		printf("%s: fork failed\n",argv[0]);
		return 1;
	}
	return status;
}
