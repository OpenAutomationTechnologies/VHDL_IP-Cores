/* pdi_spi.c - Library for FPGA PDI via SPI */
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
 File:      pdi_spi.c
 Author:    Joerg Zelenka (zelenkaj)
 Created:   2010/09/09
 Revised:   -
 State:     tested on Altera Nios II with SOPC's SPI core
------------------------------------------------------------------------------

 Functions:
            pdiSpiInit      initialize the PDI SPI driver
            
            pdiSpiWrite     write given byte to given address
            
            pdiSpiRead      read a byte from given address
            
            
            setPdiAddrReg   build addressing commands for given address
            
            sendTxBuffer    finally send the Tx Buffers in the driver instance
            
            recRxBuffer     receive one byte and store to driver instance
            
            buildCmdFrame   build a CMD Frame

------------------------------------------------------------------------------
 History:
    2010/09/09  zelenkaj    created

----------------------------------------------------------------------------*/

#include "pdi_spi.h"

/***************************************************************************************
 * LOCAL DEFINES
 ***************************************************************************************/
#define ADDR_WR_DOWN    1
#define ADDR_CHECK      2

/***************************************************************************************
 * LOCALS
 ***************************************************************************************/
/* Generates address set CMD and forwards them to the m_txBuffer
 * uwAddr_p : Address to be written to / read from
 * fWr_p :  ADDR_WR_DOWN -> writes down uwAddr_p in any case
 *          ADDR_CHECK -> checks uwAddr_p with local copy first
 *  PDISPI_OK ... Set Address Register done successfully
 *  PDISPI_ERROR ... otherwise
 */
static int setPdiAddrReg
(
    unsigned short          uwAddr_p,   //address to be accessed at PDI
    int                     fWr_p       //way of handle address change
);

/* Sends m_toBeTx bytes stored in the m_txBuffer.
 * 
 *  PDISPI_OK ... Tx done successfully
 *  PDISPI_ERROR ... otherwise
 */
static int sendTxBuffer
(
    void
);

/* Receives one byte and stores it into m_rxBuffer.
 * 
 *  PDISPI_OK ... Rx done successfully
 *  PDISPI_ERROR ... otherwise
 */
static int recRxBuffer
(
    void
);

/* Builds CMD Frame
 *  pFrame_p points to the buffer
 *  ubTyp_p identifies the CMD type:
 *      - PDISPI_CMD_HIGHADDR
 *      - PDISPI_CMD_MIDADDR
 *      - PDISPI_CMD_WR
 *      - PDISPI_CMD_RD
 *      - PDISPI_CMD_IDLE
 * 
 *  PDISPI_OK ... build done successfully
 *  PDISPI_ERROR ... otherwise
 */
static int buildCmdFrame
(
    unsigned short          uwAddr_p,   //CMD frame address
    unsigned char           *pFrame_p,  //buffer for CMD frame to be built
    unsigned char           ubTyp_p     //CMD frame type
);

/* PDI SPI Driver Instance
 */
static tPdiSpiInstance PdiSpiInstance_l;

/***************************************************************************************
 * PUBLIC FUNCTIONS
 ***************************************************************************************/

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
)
{
    int             iRet = PDISPI_OK;
    
    if( (SpiMasterTxH_p == 0) || (SpiMasterRxH_p == 0) )
    {
        iRet = PDISPI_ERROR;
        
        goto exit;
    }
    
    memset(&PdiSpiInstance_l, 0, sizeof(PdiSpiInstance_l));
    
    PdiSpiInstance_l.m_SpiMasterTxHandler = SpiMasterTxH_p;
    PdiSpiInstance_l.m_SpiMasterRxHandler = SpiMasterRxH_p;
    
    //set address register in pdi to zero
    iRet = setPdiAddrReg(0, ADDR_WR_DOWN);
    
    if( iRet != PDISPI_OK )
    {
        goto exit;
    }
    
    iRet = sendTxBuffer();

exit:
	return iRet;
}

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
)
{
    int             iRet = PDISPI_OK;
    unsigned char   ubTxData;
    
    //check the pdi's address register for the following cmd
    iRet = setPdiAddrReg(uwAddr_p, ADDR_CHECK);
    if( iRet != PDISPI_OK )
    {
        goto exit;
    }
    
    buildCmdFrame(uwAddr_p, &ubTxData, PDISPI_CMD_WR);
    
    //store CMD to Tx Buffer
    if( PdiSpiInstance_l.m_toBeTx >= PDISPI_MAX_TX )
    {   //buffer full
        iRet = PDISPI_ERROR;
        goto exit;
    }
    PdiSpiInstance_l.m_txBuffer[PdiSpiInstance_l.m_toBeTx++] = ubTxData;
    
    //store Data to Tx Buffer
    if( PdiSpiInstance_l.m_toBeTx >= PDISPI_MAX_TX )
    {   //buffer full
        iRet = PDISPI_ERROR;
        goto exit;
    }
    PdiSpiInstance_l.m_txBuffer[PdiSpiInstance_l.m_toBeTx++] = ubData_p;
    
    //send bytes in Tx buffer
    iRet = sendTxBuffer();

exit:
    return iRet;
}

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
)
{
    int             iRet = PDISPI_OK;
    unsigned char   ubTxData;
    
    //check the pdi's address register for the following cmd
    iRet = setPdiAddrReg(uwAddr_p, ADDR_CHECK);
    if( iRet != PDISPI_OK )
    {
        goto exit;
    }
    
    buildCmdFrame(uwAddr_p, &ubTxData, PDISPI_CMD_RD);
    
    //store CMD to Tx Buffer
    if( PdiSpiInstance_l.m_toBeTx >= PDISPI_MAX_TX )
    {   //buffer full
        iRet = PDISPI_ERROR;
        goto exit;
    }
    PdiSpiInstance_l.m_txBuffer[PdiSpiInstance_l.m_toBeTx++] = ubTxData;
    
    //send bytes in Tx buffer
    iRet = sendTxBuffer();
    if( iRet != PDISPI_OK )
    {
        goto exit;
    }
    
    //receive byte
    if( PdiSpiInstance_l.m_toBeRx >= PDISPI_MAX_RX )
    {   //buffer full
        iRet = PDISPI_ERROR;
        goto exit;
    }
    PdiSpiInstance_l.m_toBeRx = 1; //receive one byte
    iRet = recRxBuffer();
    if ( iRet != PDISPI_OK )
    {
        goto exit;
    }
    
    //received byte is stored in driver instance
    *pData_p = PdiSpiInstance_l.m_rxBuffer[0];
    
exit:
    return iRet;
}

/***************************************************************************************
 * LOCAL FUNCTIONS
 ***************************************************************************************/

/* Generates address set CMD and forwards them to the m_txBuffer
 * uwAddr_p : Address to be written to / read from
 * fWr_p :  ADDR_WR_DOWN -> writes down uwAddr_p in any case
 *          ADDR_CHECK -> checks uwAddr_p with local copy first
 *  PDISPI_OK ... Set Address Register done successfully
 *  PDISPI_ERROR ... otherwise
 */
static int setPdiAddrReg
(
    unsigned short          uwAddr_p,   //address to be accessed at PDI
    int                     fWr_p       //way of handle address change
)
{
    int             iRet = PDISPI_OK;
    unsigned char   ubTxData;
    
    switch(fWr_p)
    {
        case ADDR_CHECK :
            //check address with local copy
            if( (uwAddr_p & PDISPI_ADDR_HIGHADDR_MASK) == 
                (PdiSpiInstance_l.m_addrReg & PDISPI_ADDR_HIGHADDR_MASK) )
            {
                //HIGHADDR is equal to local copy(HIGHADDR) => skip
                break;
            }
        case ADDR_WR_DOWN :
        default :
            buildCmdFrame(uwAddr_p, &ubTxData, PDISPI_CMD_HIGHADDR);
            
            //store CMD to Tx Buffer
            if( PdiSpiInstance_l.m_toBeTx >= PDISPI_MAX_TX )
            {   //buffer full
                iRet = PDISPI_ERROR;
                goto exit;
            }
            PdiSpiInstance_l.m_txBuffer[PdiSpiInstance_l.m_toBeTx++] = ubTxData;
            
            break;
    }
    
    switch(fWr_p)
    {
        case ADDR_CHECK :
            //check address with local copy
            if( (uwAddr_p & PDISPI_ADDR_MIDADDR_MASK) == 
                (PdiSpiInstance_l.m_addrReg & PDISPI_ADDR_MIDADDR_MASK) )
            {
                //MIDADDR is equal to local copy(MIDADDR) => skip
                break;
            }
        case ADDR_WR_DOWN :
        default :
            buildCmdFrame(uwAddr_p, &ubTxData, PDISPI_CMD_MIDADDR);
            
            //store CMD to Tx Buffer
            if( PdiSpiInstance_l.m_toBeTx >= PDISPI_MAX_TX )
            {   //buffer full
                iRet = PDISPI_ERROR;
                goto exit;
            }
            PdiSpiInstance_l.m_txBuffer[PdiSpiInstance_l.m_toBeTx++] = ubTxData;
            break;
    }
    
    //remember the address register
    PdiSpiInstance_l.m_addrReg = uwAddr_p;

exit:
    return iRet;
}

/* Sends m_toBeTx bytes stored in the m_txBuffer.
 * 
 *  PDISPI_OK ... Tx done successfully
 *  PDISPI_ERROR ... otherwise
 */
static int sendTxBuffer
(
    void
)
{
    int             iRet = PDISPI_OK;
    
    //check number of toBeTx bytes
    if( PdiSpiInstance_l.m_toBeTx == 0 )
    {
        iRet = PDISPI_ERROR;
        goto exit;
    }
    
    //call Tx handler
    if( PdiSpiInstance_l.m_SpiMasterTxHandler == 0 )
    {
        iRet = PDISPI_ERROR;
        goto exit;
    }
    
    iRet = PdiSpiInstance_l.m_SpiMasterTxHandler(
                PdiSpiInstance_l.m_txBuffer, 
                PdiSpiInstance_l.m_toBeTx);
    
    if( iRet != PDISPI_OK )
    {
        goto exit;
    }
    
    //bytes sent...
    PdiSpiInstance_l.m_toBeTx = 0;
    
exit:
    return iRet;
}

/* Receives one byte and stores it into m_rxBuffer.
 * 
 *  PDISPI_OK ... Rx done successfully
 *  PDISPI_ERROR ... otherwise
 */
static int recRxBuffer
(
    void
)
{
    int             iRet = PDISPI_OK;
    
    //check number of toBeRx bytes
    if( PdiSpiInstance_l.m_toBeRx == 0 )
    {
        iRet = PDISPI_ERROR;
        goto exit;
    }
    
    //call Rx handler
    if( PdiSpiInstance_l.m_SpiMasterRxHandler == 0 )
    {
        iRet = PDISPI_ERROR;
        goto exit;
    }
    
    iRet = PdiSpiInstance_l.m_SpiMasterRxHandler(
                PdiSpiInstance_l.m_rxBuffer, 
                PdiSpiInstance_l.m_toBeRx);
    
    if( iRet != PDISPI_OK )
    {
        goto exit;
    }
    
    //bytes received...
    PdiSpiInstance_l.m_toBeRx = 0;
    
exit:
    return iRet;
}

/* Builds CMD Frame
 *  pFrame_p points to the buffer
 *  ubTyp_p identifies the CMD type:
 *      - PDISPI_CMD_HIGHADDR
 *      - PDISPI_CMD_MIDADDR
 *      - PDISPI_CMD_WR
 *      - PDISPI_CMD_RD
 *      - PDISPI_CMD_IDLE
 * 
 *  PDISPI_OK ... build done successfully
 *  PDISPI_ERROR ... otherwise
 */
static int buildCmdFrame
(
    unsigned short          uwAddr_p,   //CMD frame address
    unsigned char           *pFrame_p,  //buffer for CMD frame to be built
    unsigned char           ubTyp_p     //CMD frame type
)
{
    int         iRet = PDISPI_OK;
    
    switch(ubTyp_p)
    {
        case PDISPI_CMD_HIGHADDR :
            *pFrame_p = (unsigned char) ((uwAddr_p & PDISPI_ADDR_HIGHADDR_MASK) \
                                        >> PDISPI_ADDR_HIGHADDR_OFFSET \
                                        | PDISPI_CMD_HIGHADDR);
            break;
        case PDISPI_CMD_MIDADDR :
            *pFrame_p = (unsigned char) ((uwAddr_p & PDISPI_ADDR_MIDADDR_MASK) \
                                        >> PDISPI_ADDR_MIDADDR_OFFSET \
                                        | PDISPI_CMD_MIDADDR);
            break;
        case PDISPI_CMD_WR :
            *pFrame_p = (unsigned char) ((uwAddr_p & PDISPI_ADDR_ADDR_MASK) \
                                        >> 0 \
                                        | PDISPI_CMD_WR);
            break;
        case PDISPI_CMD_RD :
            *pFrame_p = (unsigned char) ((uwAddr_p & PDISPI_ADDR_ADDR_MASK) \
                                        >> 0 \
                                        | PDISPI_CMD_RD);
            break;
        case PDISPI_CMD_IDLE :
        default :
            iRet = PDISPI_OK;
            break;
    }
    
    return iRet;
}
