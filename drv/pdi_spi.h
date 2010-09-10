/* pdi_spi.h - Library for FPGA PDI via SPI */
/*
------------------------------------------------------------------------------
Copyright (c) 2010, B&R
All rights reserved.

Redistribution and use in source and binary forms,
with or without modification,
are permitted provided that the following conditions are met:

- Redistributions of source code must retain the above copyright notice,
this list of conditions and the following disclaimer.

- Redistributions in binary form must reproduce the above copyright notice,
this list of conditions and the following disclaimer
in the documentation and/or other materials provided with the distribution.

- Neither the name of the B&R nor the names of
its contributors may be used to endorse or promote products derived
from this software without specific prior written permission.


THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO,
THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR
PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR
CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL,
EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS;
OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY,
WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR
OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE,
EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

------------------------------------------------------------------------------
 Module:    pdi_spi
 File:      pdi_spi.h
 Author:    Joerg Zelenka (zelenkaj)
 Created:   2010/09/09
 Revised:   -
 State:     tested on Altera Nios II with SOPC's SPI core
------------------------------------------------------------------------------

 Functions:
            pdiSpiInit      initialize the PDI SPI driver
            
            pdiSpiWrite     write given byte to given address
            
            pdiSpiRead      read a byte from given address

------------------------------------------------------------------------------
 History:
    2010/09/09  zelenkaj    created

----------------------------------------------------------------------------*/

#ifndef PDI_SPI_H_
#define PDI_SPI_H_

//errors
#define PDISPI_OK                       (0)
#define PDISPI_ERROR                    (-1)

//general define
#define PDISPI_MAX_TX                   (4)
#define PDISPI_MAX_RX                   (1)

//CMD Frame:
// CMD(2..0) | DATA(4..0)
#define PDISPI_CMD_OFFSET               (5)
#define PDISPI_CMD_HIGHADDR             (0x4) << PDISPI_CMD_OFFSET //0b100
#define PDISPI_CMD_MIDADDR              (0x5) << PDISPI_CMD_OFFSET //0b101
#define PDISPI_CMD_WR                   (0x6) << PDISPI_CMD_OFFSET //0b110
#define PDISPI_CMD_RD                   (0x7) << PDISPI_CMD_OFFSET //0b111
#define PDISPI_CMD_IDLE                 (0x0) << PDISPI_CMD_OFFSET //0b0XX

//ADDR pattern
#define PDISPI_ADDR_HIGHADDR_OFFSET     (10)
#define PDISPI_ADDR_MIDADDR_OFFSET      (5)
#define PDISPI_ADDR_ADDR_OFFSET         (0)
#define PDISPI_ADDR_MASK                (0x1F)
#define PDISPI_ADDR_HIGHADDR_MASK       PDISPI_ADDR_MASK << PDISPI_ADDR_HIGHADDR_OFFSET
#define PDISPI_ADDR_MIDADDR_MASK        PDISPI_ADDR_MASK << PDISPI_ADDR_MIDADDR_OFFSET
#define PDISPI_ADDR_ADDR_MASK           PDISPI_ADDR_MASK << PDISPI_ADDR_ADDR_OFFSET


/* SPI Master Tx/Rx Handler
 * Tx Handler: Is called to transmit n bytes of data. pTxBuf_p points
 *  to the first byte to be transmitted.
 * Rx Handler: Is called to receive 1 byte of data.
 *  Note: The Master must send a byte with MSB '0', when receiving data.
  * return:
 *  PDISPI_OK ... Tx/Rx done successfully
 *  PDISPI_ERROR ... otherwise
 */
typedef int (*tSpiMasterTxHandler) (unsigned char *pTxBuf_p, int iBytes_p);
typedef int (*tSpiMasterRxHandler) (unsigned char *pRxBuf_p, int iBytes_p);

typedef struct _tPdiSpiInstance
{
	//Tx Handler of the SPI Master Component
    tSpiMasterTxHandler     m_SpiMasterTxHandler;
    //Rx Handler of the SPI Master Component
    tSpiMasterRxHandler     m_SpiMasterRxHandler;
	
    //Local copy of the Address Register of the PDI SPI Slave
    unsigned short          m_addrReg;
    
    //Tx Buffer
    unsigned char           m_txBuffer[PDISPI_MAX_TX];
    int                     m_toBeTx;
    //Rx Buffer
    unsigned char           m_rxBuffer[PDISPI_MAX_RX];
    int                     m_toBeRx;
} tPdiSpiInstance;

/* PDI SPI Driver Init
 *  Has to be called before using any other function of this library to register the
 *  SPI Master Tx/Rx handler.
 *  Furthermore the function sets the Address Register of the PDI SPI Slave to a known
 *  state.
 * return:
 *  PDISPI_OK ... init done successfully
 *  PDISPI_ERROR ... otherwise
 */
int pdiSpiInit
(
    tSpiMasterTxHandler     SpiMasterTxH_p, //SPI Master Tx Handler 
    tSpiMasterRxHandler     SpiMasterRxH_p  //SPI MASTER Rx Handler
);

/* PDI SPI Driver Write
 *  This function writes a byte (ubData_p) to the PDI at the given address
 *  (uwAddr_p).
 * return:
 *  PDISPI_OK ... write done successfully
 *  PDISPI_ERROR ... otherwise
 */
int pdiSpiWrite
(
    unsigned short          uwAddr_p,       //PDI Address to be written to
    unsigned char           ubData_p        //Write data
);

/* PDI SPI Driver Read
 *  This function reads a byte (pData_p) from the PDI at a given address
 *  (uwAddr_p).
 * return:
 *  PDISPI_OK ... read done successfully
 *  PDISPI_ERROR ... otherwise
 */
int pdiSpiRead
(
    unsigned short          uwAddr_p,       //PDI Address to be read from
    unsigned char           *pData_p        //Read data
);

#endif /* PDI_SPI_H_ */
