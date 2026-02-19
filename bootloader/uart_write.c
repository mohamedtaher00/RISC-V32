// uart_write.c: Write data from file into connected UART.
// Usage: uart_write <serial_device> <number_of_byte> <data_file>
// Example use (write one byte from file to /dev/USBtty)
// ./uart_write /dev/USBtty 1 file
// Example use (write all file to /dev/USBtty)
// ./uart_write /dev/USBtty file

#include <stdio.h>
#include <stdlib.h>
#include <termios.h>
#include <fcntl.h>
#include <unistd.h>
#include <errno.h>

char buff[1024];
int fserial;
int fdata;

int main(int argc, const char** argv){
	if(argc != 4 && argc != 3){
		printf("Usage: %s <serial_device> <no_bytes> <data_file>\n",argv[0]);	
		return 1;
	}
	if((fserial= open(argv[1], O_RDWR | O_NOCTTY)) < 0){
		printf("%s: Cannot open %s\n", argv[0], argv[1]);
		return(1);
	}
	if(argc == 3){
		if((fdata = open(argv[2], O_RDONLY)) < 0){
			printf("%s: Cannot open %s\n", argv[0], argv[3]);
			return(1);
		}
	}
	else if(argc == 4){
		if((fdata = open(argv[3], O_RDONLY)) < 0){
			printf("%s: Cannot open %s\n", argv[0], argv[3]);
			return(1);
		}
	}

	struct termios uart; 
	tcgetattr(fserial, &uart);

	// Set raw mode
    uart.c_iflag &= ~(IGNBRK | BRKINT | PARMRK | ISTRIP | IGNCR | ICRNL | IXON);
    uart.c_oflag &= ~OPOST;
    uart.c_lflag &= ~(ECHO | ECHONL | ICANON | ISIG | IEXTEN);
    uart.c_cflag &= ~(CSIZE | PARENB);
    uart.c_cflag |= CS8;

	cfsetospeed(&uart, B9600);
	cfsetispeed(&uart, B9600);

	if(argc == 4){
		int nobytes = atoi(argv[2]);
		if(nobytes == 0){
			printf("%s: Unable to write %s\n", argv[0], argv[2]);
			return -1;
		}
		for(int i = 0; i < nobytes; i++){
			if (read(fdata, &buff[i], 1) != 1){
				printf("%s: Could not read from %s\n", argv[0], argv[3]);
				return 1;
			}
			if (write(fserial, &buff[i], 1) != 1){
				printf("%s: Could not write to serial %s\n", argv[0], argv[1]);
				printf("errno: %d\n fd: %d", errno, fserial);
				return 1;
			}
		}
	}
	else{
		for(int i=0,end=1; end != 0; i++){
			if ((end = read(fdata, &buff[i], 1)) < 0){
				printf("%s: Could not read from %s\n", argv[0], argv[3]);
				return 1;
			}
			if (write(fserial, &buff[i], 1) != 1){
				printf("%s: Could not write to serial %s\n", argv[0], argv[1]);
				printf("errno: %d\n fd: %d", errno, fserial);
				return 1;
			}
		}
	}
	if(close(fdata) != 0)
		return -1; 	
	if(close(fserial) != 0)
		return -1; 	
	return 0;
}
