/* Calculating XMODEM CRC-16 in 'C'
   ================================
   Reference model for the translated code */

#include <stdio.h>
#include <fcntl.h>
#include <stdlib.h>

#define poly 0x1021

/* On entry, addr=>start of data
             num = length of data
             crc = incoming CRC     */
int crc16(char *addr, int num, int crc)
{
int i;

for (; num>0; num--)               /* Step through bytes in memory */
  {
  crc = crc ^ (*addr++ << 8);      /* Fetch byte from memory, XOR into CRC top byte*/
  for (i=0; i<8; i++)              /* Prepare to rotate 8 bits */
    {
    crc = crc << 1;                /* rotate */
    if (crc & 0x10000)             /* bit 15 was set (now bit 16)... */
      crc = (crc ^ poly) & 0xFFFF; /* XOR with XMODEM polynomic */
                                   /* and ensure CRC remains 16-bit value */
    }                              /* Loop for 8 bits */
  }                                /* Loop until num=0 */
  return(crc);                     /* Return updated CRC */
}


#define MAXBUF (256*1024)

void main(int argc, char **argv)
{
      int fd = 0;
      int nr;
      char buf[MAXBUF];
      unsigned short crc;

      if( argc > 1 )
      {
            if( (fd = open( argv[1], O_RDONLY )) < 0 )
            {
                  perror( argv[1] );
                  exit( -1 );
            }
      }
      crc = 0;
      while( (nr = read( fd, buf, MAXBUF )) > 0 )
	crc = crc16( buf, nr , 0);
      printf( "%04X\n", crc );
      if( nr != 0 )
            perror( "reading" );
}

