#ifndef _CC2420_X_SPI_H_
#define _CC2420_X_SPI_H_

/*
 * /brief define the operations on spi data and control registers
 */
#define CSN       2  /* P4.2 - Output: SPI Chip Select */
#define SCK       1  /* P3.1 - Output: SPI Serial Clock (SCLK) */
#define MOSI      2  /* P3.2 - Output: SPI Master out - slave in (MOSI) */
#define MISO      3  /* P3.3 - Input:  SPI Master in - slave out (MISO) */

#define CC2420_SPI_DISABLE() ( P4OUT |= BV(CSN) )  /* DISABLE CSn */
#define CC2420_SPI_ENABLE() ( P4OUT &= ~BV(CSN) )  /* ENABLE CSn */

void cc2420_spi_init() {
  static unsigned char spi_inited = 0;

  if (spi_inited)
    return;

  /* Initalize ports for communication with SPI units. */

  U0CTL  = CHAR + SYNC + MM + SWRST;      /* SW reset,8-bit transfer, SPI master */
  U0TCTL = CKPH + SSEL1 + STC;            /* Data on Rising Edge, SMCLK, 3-wire. */

  U0BR0  = 0x02;                          /* SPICLK set baud. */
  U0BR1  = 0;                             /* Dont need baud rate control register 2 - clear it */
  U0MCTL = 0;                             /* Dont need modulation control. */

  P3SEL |= BV(SCK) | BV(MOSI) | BV(MISO); /* Select Peripheral functionality */
  P3DIR |= BV(SCK) | BV(MISO);            /* Configure as outputs(SIMO,CLK). */

  ME1   |= USPIE0;                        /* Module enable ME1 */
  U0CTL &= ~SWRST;                        /* Remove RESET */
}

static inline void fast_read_one(uint8_t* buf) {
  uint8_t tmp;

  CC2420_SPI_DISABLE();
  CC2420_SPI_ENABLE();

  U0TXBUF = CC2420_RXFIFO | 0x40;
  while ( !(IFG1 & URXIFG0) );
  tmp = U0RXBUF;

  while ( !(IFG1 & UTXIFG0) );
  U0TXBUF = 0;
  while ( !(IFG1 & URXIFG0) );
  buf[0] = U0RXBUF;
}

static inline void fast_continue_read_one(uint8_t* buf) {
  while ( !(IFG1 & UTXIFG0) );
  U0TXBUF = 0;
  while ( !(IFG1 & URXIFG0) );
  buf[0] = U0RXBUF;
}

static inline void fast_continue_read_tail(uint8_t* buf, uint8_t len) {
  uint8_t idx;
  uint8_t tmp;

  for (idx = 0; idx < len; idx++) {
    while ( !(IFG1 & UTXIFG0) );
    U0TXBUF = 0;
    while ( !(IFG1 & URXIFG0) );
    buf[idx] = U0RXBUF;
  }

  CC2420_SPI_DISABLE();
}

static inline void fast_read_any(uint8_t* buf, uint8_t len) {
  uint8_t idx;
  uint8_t tmp;

  CC2420_SPI_DISABLE();
  CC2420_SPI_ENABLE();

  U0TXBUF = CC2420_RXFIFO | 0x40;
  while ( !(IFG1 & URXIFG0) );
  tmp = U0RXBUF;

  for (idx = 0; idx < len; idx++) {
    while ( !(IFG1 & UTXIFG0) );
    U0TXBUF = 0;
    while ( !(IFG1 & URXIFG0) );
    buf[idx] = U0RXBUF;
  }

  CC2420_SPI_DISABLE();
}

static inline void fast_write_any(uint8_t* buf, uint8_t len) {
  uint8_t idx;
  uint8_t tmp;

  CC2420_SPI_DISABLE();
  CC2420_SPI_ENABLE();

  U0TXBUF = CC2420_TXFIFO;

  for (idx = 0; idx < len; idx++) {
    while ( !(IFG1 & URXIFG0) );
    tmp = U0RXBUF;
    while ( !(IFG1 & UTXIFG0) );
    U0TXBUF = buf[idx];
  }

  while ( !(IFG1 & URXIFG0) );
  tmp = U0RXBUF;

  CC2420_SPI_DISABLE();
}

static inline uint8_t strobe(uint8_t reg) {
  uint8_t tmp;

  CC2420_SPI_DISABLE();
  CC2420_SPI_ENABLE();

  U0TXBUF = reg;
  while ( !(IFG1 & URXIFG0) );
  tmp = U0RXBUF;

  CC2420_SPI_DISABLE();

  return tmp;
}

static inline uint16_t get_register(uint8_t reg) {
  uint8_t tmp;
  uint16_t val;

  CC2420_SPI_DISABLE();
  CC2420_SPI_ENABLE();

  U0TXBUF = (reg | 0x40);
  while ( !(IFG1 & URXIFG0) );
  tmp = U0RXBUF;
  while ( !(IFG1 & UTXIFG0) );
  U0TXBUF = 0;
  while ( !(IFG1 & URXIFG0) );
  val = (U0RXBUF << 8);
  while ( !(IFG1 & UTXIFG0) );
  U0TXBUF = 0;
  while ( !(IFG1 & URXIFG0) );
  val |= U0RXBUF;

  CC2420_SPI_DISABLE();

  return val;
}

static inline void set_register(uint8_t reg, uint16_t val) {
  uint8_t tmp;

  CC2420_SPI_DISABLE();
  CC2420_SPI_ENABLE();

  U0TXBUF = reg;
  while ( !(IFG1 & URXIFG0) );
  tmp = U0RXBUF;
  while ( !(IFG1 & UTXIFG0) );
  U0TXBUF = (val >> 8);
  while ( !(IFG1 & URXIFG0) );
  tmp = U0RXBUF;
  while ( !(IFG1 & UTXIFG0) );
  U0TXBUF = (val & 0xff);
  while ( !(IFG1 & URXIFG0) );
  tmp = U0RXBUF;

  CC2420_SPI_DISABLE();
}

static inline void read_ram(uint16_t addr, uint16_t offset, uint8_t* data, uint8_t len) {
  uint8_t idx;
  uint8_t tmp;

  CC2420_SPI_DISABLE();
  CC2420_SPI_ENABLE();

  addr += offset;
  U0TXBUF = ( (addr & 0x7f) | 0x80 );
  while ( !(IFG1 & URXIFG0) );
  tmp = U0RXBUF;
  while ( !(IFG1 & UTXIFG0) );
  U0TXBUF = ( ( (addr >> 1) & 0xc0) | 0x20 );
  while ( !(IFG1 & URXIFG0) );
  tmp = U0RXBUF;

  for (idx = 0; idx < len; idx++) {
    while ( !(IFG1 & UTXIFG0) );
    U0TXBUF = 0;
    while ( !(IFG1 & URXIFG0) );
    data[idx] = U0RXBUF;
  }

  CC2420_SPI_DISABLE();
}

static inline void write_ram(uint16_t addr, uint16_t offset, uint8_t* data, uint8_t len) {
  uint8_t idx;
  uint8_t tmp;

  CC2420_SPI_DISABLE();
  CC2420_SPI_ENABLE();

  addr += offset;
  U0TXBUF = ( (addr & 0x7f) | 0x80);
  while ( !(IFG1 & URXIFG0) );
  tmp = U0RXBUF;
  while ( !(IFG1 & UTXIFG0) );
  U0TXBUF = ( (addr >> 1) & 0xc0 );

  for (idx = 0; idx < len; idx++) {
    while ( !(IFG1 & URXIFG0) );
    tmp = U0RXBUF;
    while ( !(IFG1 & UTXIFG0) );
    U0TXBUF = data[idx];
  }

  while ( !(IFG1 & URXIFG0) );
  tmp = U0RXBUF;

  CC2420_SPI_DISABLE();
}

#endif
