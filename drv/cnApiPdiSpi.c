/**
********************************************************************************
\file		cnApiPdiSpi.c

\brief		Library for FPGA PDI via SPI

\author		Joerg Zelenka

\date		2010/09/09

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

 Functions:
            CnApi_initSpiMaster     initialize the PDI SPI driver
            
            CnApi_Spi_write         write given data size from PDI

            CnApi_Spi_read          read given data size to PDI


            CnApi_Spi_writeByte     write given byte to given address
            
            CnApi_Spi_readByte      read a byte from given address
            
            CnApi_Spi_writeSq     	write given bytes to given address

            CnApi_Spi_readSq      	read bytes from given address
            
            setPdiAddrReg   build addressing commands for given address
            
            sendTxBuffer    finally send the Tx Buffers in the driver instance
            
            recRxBuffer     receive one byte and store to driver instance
            
            buildCmdFrame   build a CMD Frame

------------------------------------------------------------------------------
 History:
    2010/09/09  zelenkaj    created
	2010/10/25	hoggerm		added function for scalable data size transfers
	2010/12/13	zelenkaj	added sq-functionality

*******************************************************************************/

#include "cnApiPdiSpi.h"
#include "cnApiDebug.h"

/***************************************************************************************
 * LOCAL DEFINES
 ***************************************************************************************/
#define ADDR_WR_DOWN    1
#define ADDR_CHECK      2
#define ADDR_WR_DOWN_LO 3
#define ADDR_CHECK_LO   4

/***************************************************************************************
 * LOCALS
 ***************************************************************************************/

static int setPdiAddrReg
(
    unsigned short          uwAddr_p,   //address to be accessed at PDI
    int                     fWr_p       //way of handle address change
);

static int sendTxBuffer
(
    void
);

static int recRxBuffer
(
    void
);

static int buildCmdFrame
(
    unsigned short          uwPayload_p,   //CMD frame address
    unsigned char           *pFrame_p,  //buffer for CMD frame to be built
    unsigned char           ubTyp_p     //CMD frame type
);

/* PDI SPI Driver Instance
 */
static tPdiSpiInstance PdiSpiInstance_l;

/***************************************************************************************
 * PUBLIC FUNCTIONS
 ***************************************************************************************/

/**
********************************************************************************
\brief  initializes the local SPI Master and the PDI SPI

CnApi_initSpiMaster() has to be called before using any other function of
this library to register the SPI Master Tx/Rx handler.
Furthermore the function sets the Address Register of the PDI SPI Slave
to a known state.

\param  SpiMasterTxH_p     SPI Master Tx Handler callback
\param  SpiMasterRxH_p     SPI Master Rx Handler callback

\retval iRet        can be PDISPI_OK if transfer was successful
                    or PDISPI_ERROR otherwise
*******************************************************************************/
int CnApi_initSpiMaster
(
    tSpiMasterTxHandler     SpiMasterTxH_p, ///< SPI Master Tx Handler
    tSpiMasterRxHandler     SpiMasterRxH_p  ///< SPI MASTER Rx Handler
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
    
    //send out idle frames to enter idle surely!
    // note: fsm could be in WRSQ or RDSQ
    PdiSpiInstance_l.m_toBeTx = PDISPI_MAX_SQ;

    //send bytes in Tx buffer
    iRet = sendTxBuffer();

    //set address register in pdi to zero
    iRet = setPdiAddrReg(0, ADDR_WR_DOWN_LO);
    
    if( iRet != PDISPI_OK )
    {
        goto exit;
    }
    
    iRet = sendTxBuffer();

exit:
	return iRet;
}

/**
********************************************************************************
\brief  write byte to the CN PDI via SPI

CnApi_Spi_writeByte() writes one byte to the POWERLINK CN PDI via SPI.
This byte will be written to PDI address.

\param  uwAddr_p    PDI address to be written to
\param  pData_p     Write data

\retval iRet        can be PDISPI_OK if transfer was successful
                    or PDISPI_ERROR otherwise
*******************************************************************************/
int CnApi_Spi_writeByte
(
    WORD          uwAddr_p,       ///< PDI Address to be written to
    BYTE           ubData_p        ///< Write data
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

    PdiSpiInstance_l.m_addrReg++;

exit:
    return iRet;
}

/**
********************************************************************************
\brief  write data to the CN PDI via SPI

CnApi_Spi_writeSq() writes several bytes to the POWERLINK CN PDI via SPI.
This data will be written to PDI address.

\param  uwAddr_p    PDI address to be written to
\param  uwSize_p    Write data size
\param  pData_p     Write data

\retval iRet        can be PDISPI_OK if transfer was successful
                    or PDISPI_ERROR otherwise
*******************************************************************************/
int CnApi_Spi_writeSq
(
    WORD            uwAddr_p,       ///< PDI Address to be written to
    WORD            uwSize_p,       ///< Write data size (bytes)
    BYTE            *pData_p        ///< Write data
)
{
    int             iRet = PDISPI_OK;
    unsigned char   ubTxData;
    WORD            uwTxSize = 0;

    //check the pdi's address register for the following cmd
    iRet = setPdiAddrReg(uwAddr_p, ADDR_CHECK_LO);
    if( iRet != PDISPI_OK )
    {
        goto exit;
    }

    do
    {
        if( uwSize_p > PDISPI_MAX_SQ )
        {
            uwTxSize = PDISPI_MAX_SQ;
            uwSize_p -= PDISPI_MAX_SQ;
        }
        else
        {
            uwTxSize = uwSize_p;
            uwSize_p = 0;
        }

        //build WRSQ command with bytes-1 as payload
        buildCmdFrame(uwTxSize-1, &ubTxData, PDISPI_CMD_WRSQ);

        //store CMD to Tx Buffer
        if( PdiSpiInstance_l.m_toBeTx >= PDISPI_MAX_TX )
        {   //buffer full
            iRet = PDISPI_ERROR;
            goto exit;
        }
        PdiSpiInstance_l.m_txBuffer[PdiSpiInstance_l.m_toBeTx++] = ubTxData;

        //add tx data to tx buffer
        if( (PdiSpiInstance_l.m_toBeTx-1 + uwTxSize) >= PDISPI_MAX_TX )
        {   //buffer full
            iRet = PDISPI_ERROR;
            goto exit;
        }

        memcpy((BYTE*)&PdiSpiInstance_l.m_txBuffer[PdiSpiInstance_l.m_toBeTx], pData_p, uwTxSize);
        pData_p += uwTxSize; //increment to next buffer position
        PdiSpiInstance_l.m_toBeTx += uwTxSize;

        //send bytes in Tx buffer
        iRet = sendTxBuffer();
        if( iRet != PDISPI_OK )
        {
            goto exit;
        }

        PdiSpiInstance_l.m_addrReg += uwTxSize; //increment local copy too!
    }
    while( uwSize_p );

exit:
    return iRet;
}

/**
********************************************************************************
\brief  read one byte from the CN PDI via SPI

CnApi_Spi_readByte() reads one byte from the POWERLINK CN PDI via SPI.
This data will be read from PDI address and stored to a local address.

\param  uwAddr_p     PDI address to be read from
\param  pData_p      Read data

\retval iRet        can be PDISPI_OK if transfer was successful
                    or PDISPI_ERROR otherwise
*******************************************************************************/
int CnApi_Spi_readByte
(
    WORD          uwAddr_p,       ///< PDI Address to be read from
    BYTE           *pData_p        ///< Read data
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
    
    PdiSpiInstance_l.m_addrReg++;

exit:
    return iRet;
}

/**
********************************************************************************
\brief  read data from the CN PDI via SPI

CnApi_Spi_readSq() reads several bytes from the POWERLINK CN PDI via SPI.
This data will be read from PDI address and stored to a local address.

\param  uwAddr_p     PDI address to be read from
\param uwSize_p      Read data size (in bytes)
\param  pData_p      Read data

\retval iRet        can be PDISPI_OK if transfer was successful
                    or PDISPI_ERROR otherwise
*******************************************************************************/
int CnApi_Spi_readSq
(
    WORD            uwAddr_p,       ///< PDI Address to be read from
    WORD            uwSize_p,       ///< Read data size
    BYTE            *pData_p        ///< Read data
)
{
    int             iRet = PDISPI_OK;
    unsigned char   ubTxData;
    WORD            uwRxSize = 0;

    //check the pdi's address register for the following cmd
    iRet = setPdiAddrReg(uwAddr_p, ADDR_CHECK_LO);
    if( iRet != PDISPI_OK )
    {
        goto exit;
    }

    do
    {
        if( uwSize_p > PDISPI_MAX_SQ )
        {
            uwRxSize = PDISPI_MAX_SQ;
            uwSize_p -= PDISPI_MAX_SQ;
        }
        else
        {
            uwRxSize = uwSize_p;
            uwSize_p = 0;
        }

        //build RDSQ command with bytes-1 as payload
        buildCmdFrame(uwRxSize-1, &ubTxData, PDISPI_CMD_RDSQ);

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
        if( (PdiSpiInstance_l.m_toBeRx-1 + uwRxSize) >= PDISPI_MAX_RX )
        {   //buffer full
            iRet = PDISPI_ERROR;
            goto exit;
        }
        PdiSpiInstance_l.m_toBeRx += uwRxSize;
        iRet = recRxBuffer();
        if ( iRet != PDISPI_OK )
        {
            goto exit;
        }

        //received bytes are stored in driver instance
        //*pData_p = PdiSpiInstance_l.m_rxBuffer[0];
        memcpy(pData_p, (BYTE*)&PdiSpiInstance_l.m_rxBuffer[0], uwRxSize);
        pData_p += uwRxSize; //increment to next buffer position
        PdiSpiInstance_l.m_addrReg += uwRxSize; //increment local copy too!
    }
    while( uwSize_p );

exit:
    return iRet;
}

/**
********************************************************************************
\brief	read data from the CN PDI via SPI

CnApi_Spi_read() reads a certain amount of data from the POWERLINK CN PDI
via SPI. This data will be read from PDI address and stored to a local address.

\param	wAddr_p		PDI address to be read from
\param	wSize_p		Size of transmitted data in Bytes
\param  pTgtVar     (Byte-) Pointer to local target address

\retval	iRet		can be PDISPI_OK if transfer was successful
					or PDISPI_ERROR otherwise
*******************************************************************************/
int CnApi_Spi_read
(
   WORD   wPcpAddr_p,      ///< PDI Address to be read from
   WORD   wSize_p,         ///< size in Bytes
   BYTE*  pApTgtVar_p      ///< ptr to local target
)
{
    int iRet = PDISPI_OK;

    /* Depending on data size, choose different SPI processing*/
    if((wSize_p > PDISPI_MAX_SIZE) || wSize_p == 0)
    {
        TRACE("Error: SPI PDI data size invalid!");
        iRet = PDISPI_ERROR;
        goto exit;
    }
    else if(wSize_p > PDISPI_THRSHLD_SIZE) /* use automatic address increment */
    {

    	iRet = CnApi_Spi_readSq(wPcpAddr_p, wSize_p, pApTgtVar_p);
        if( iRet != PDISPI_OK )
        {
            iRet = PDISPI_ERROR;
            goto exit;
        }

    }
    else /* transfer single bytes - in this case, better use CnApi_Spi_readByte() directly! */
    {
        for(; 0 < wSize_p; wSize_p--)
         {
             iRet = CnApi_Spi_readByte(wPcpAddr_p++, (BYTE*) (pApTgtVar_p++));
             if( iRet != PDISPI_OK )
             {
                 iRet = PDISPI_ERROR;
                 goto exit;
             }
         }
    }

    exit:
        return iRet;
}

/**
********************************************************************************
\brief  write data to the CN PDI via SPI

CnCnApi_Spi_writerites a certain amount of data to the POWERLINK CN PDI
via SPI. This data will be read from a local address and stored to a PDI address.

\param  wAddr_p     PDI Address to be written to
\param  wSize_p     Size of transmitted data in Bytes
\param  pSrcVar     (Byte-) Pointer to local source address

\retval iRet        can be PDISPI_OK if transfer was successful
                    or PDISPI_ERROR otherwise
*******************************************************************************/
int CnApi_Spi_write
(
    WORD   wPcpAddr_p,    ///< PDI Address to be written to
    WORD   wSize_p,                             ///< size in Bytes
    BYTE*  pApSrcVar_p                          ///< ptr to local source
)
{
    int iRet = PDISPI_OK;

    /* Depending on data size, choose different SPI processing*/
    if((wSize_p > PDISPI_MAX_SIZE) || wSize_p == 0)
    {
        TRACE("Error: SPI PDI data size invalid!");
        iRet = PDISPI_ERROR;
        goto exit;
    }
    else if(wSize_p > PDISPI_THRSHLD_SIZE) /* use automatic address increment */
    {

    	iRet = CnApi_Spi_writeSq(wPcpAddr_p, wSize_p, pApSrcVar_p);
        if( iRet != PDISPI_OK )
        {
            iRet = PDISPI_ERROR;
            goto exit;
        }

    }
    else /* transfer single bytes - in this case, better use CnApi_Spi_writeByte directly! */
    {
        for(; 0 < wSize_p; wSize_p--)
         {
          iRet = CnApi_Spi_writeByte(wPcpAddr_p++, (BYTE) *(pApSrcVar_p++));
             if( iRet != PDISPI_OK )
             {
                 iRet = PDISPI_ERROR;
                 goto exit;
             }
         }
    }

    exit:
        return iRet;
}
/***************************************************************************************
 * LOCAL FUNCTIONS
 ***************************************************************************************/

/**
********************************************************************************
\brief  set the PDI address register

setPdiAddrReg() sets the PDI SPI address register (local copy and
in the IP-core). If the fWr_p is set to ADDR_CHECK/ADDR_CHECK_LO the local copy
is checked with uwAddr_p first to save SPI writes. Otherwise the uwAddr_p is
written down without verification.

\param  uwAddr_p    address to be accessed at PDI
\param  fWr_p    	way of handle address change

\retval iRet        PDISPI_OK if address register is set correctly
					PDISPI_ERROR otherwise (e.g. full TX buffer)
*******************************************************************************/
static int setPdiAddrReg
(
    unsigned short          uwAddr_p,   ///< address to be accessed at PDI
    int                     fWr_p       ///< way of handle address change
)
{
    int             iRet = PDISPI_OK;
    unsigned char   ubTxData;
    
    //check high address first
    switch(fWr_p)
    {
        case ADDR_CHECK :
        case ADDR_CHECK_LO :
            //check address with local copy
            if( (uwAddr_p & PDISPI_ADDR_HIGHADDR_MASK) == 
                (PdiSpiInstance_l.m_addrReg & PDISPI_ADDR_HIGHADDR_MASK) )
            {
                //HIGHADDR is equal to local copy(HIGHADDR) => skip
                break;
            }
        case ADDR_WR_DOWN :
        case ADDR_WR_DOWN_LO :
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
    
    //check mid address
    switch(fWr_p)
    {
        case ADDR_CHECK :
        case ADDR_CHECK_LO :
            //check address with local copy
            if( (uwAddr_p & PDISPI_ADDR_MIDADDR_MASK) == 
                (PdiSpiInstance_l.m_addrReg & PDISPI_ADDR_MIDADDR_MASK) )
            {
                //MIDADDR is equal to local copy(MIDADDR) => skip
                break;
            }
        case ADDR_WR_DOWN :
        case ADDR_WR_DOWN_LO :
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
    
    //check low address only if fWr_p is set to ???_LO
    switch(fWr_p)
    {
        case ADDR_CHECK_LO :
            //check address with local copy
            if( (uwAddr_p & PDISPI_ADDR_LOWADDR_MASK) ==
                (PdiSpiInstance_l.m_addrReg & PDISPI_ADDR_LOWADDR_MASK) )
            {
                //LOWADDR is equal to local copy(LOWADDR) => skip
                break;
            }
        case ADDR_WR_DOWN_LO :
            buildCmdFrame(uwAddr_p, &ubTxData, PDISPI_CMD_LOWADDR);

            //store CMD to Tx Buffer
            if( PdiSpiInstance_l.m_toBeTx >= PDISPI_MAX_TX )
            {   //buffer full
                iRet = PDISPI_ERROR;
                goto exit;
            }
            PdiSpiInstance_l.m_txBuffer[PdiSpiInstance_l.m_toBeTx++] = ubTxData;
            break;
        default :
            break;
    }

    //remember the address register
    PdiSpiInstance_l.m_addrReg = uwAddr_p;

exit:
    return iRet;
}

/**
********************************************************************************
\brief  Transmit m_toBeTx byte(s) and store it/them to m_txBuffer

sendTxBuffer() calls the SPI master TX handler. The to be sent bytes should be
stored in m_txBuffer.

\retval iRet        PDISPI_OK - RX done / otherwise error!
*******************************************************************************/
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

/**
********************************************************************************
\brief  Receive m_toBeRx byte(s) and store it/them to m_rxBuffer

recRxBuffer() calls the SPI master RX handler. The received bytes are stored
in m_rxBuffer.

\retval iRet        PDISPI_OK - RX done / otherwise error!
*******************************************************************************/
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

/**
********************************************************************************
\brief  Build command frame

buildCmdFrame() builds the possible command frames in the byte pFrame_p. The
payload of the frame (e.g. address of WR cmd or span of WRSQ cmd) is taken from
uwPayload_p. ubType_p gives the command type (use defines).

\param  uwPayload_p    cmd frame payload
\param  pFrame_p    frame buffer pointer
\param  ubTyp_p     cmd frame type

\retval iRet        can be PDISPI_OK only - if ubTyp_p is unknown, idle frame
					is returned!
*******************************************************************************/
static int buildCmdFrame
(
    unsigned short          uwPayload_p,   ///< CMD frame payload
    unsigned char           *pFrame_p,  ///< buffer for CMD frame to be built
    unsigned char           ubTyp_p     ///< CMD frame type
)
{
    int         iRet = PDISPI_OK;
    
    switch(ubTyp_p)
    {
        case PDISPI_CMD_HIGHADDR :
            *pFrame_p = (unsigned char) ((uwPayload_p & PDISPI_ADDR_HIGHADDR_MASK) \
                                        >> PDISPI_ADDR_HIGHADDR_OFFSET \
                                        | PDISPI_CMD_HIGHADDR);
            break;
        case PDISPI_CMD_MIDADDR :
            *pFrame_p = (unsigned char) ((uwPayload_p & PDISPI_ADDR_MIDADDR_MASK) \
                                        >> PDISPI_ADDR_MIDADDR_OFFSET \
                                        | PDISPI_CMD_MIDADDR);
            break;
        case PDISPI_CMD_LOWADDR :
            *pFrame_p = (unsigned char) ((uwPayload_p & PDISPI_ADDR_LOWADDR_MASK) \
                                        >> PDISPI_ADDR_LOWADDR_OFFSET \
                                        | PDISPI_CMD_LOWADDR);
            break;
        case PDISPI_CMD_WR :
            *pFrame_p = (unsigned char) ((uwPayload_p & PDISPI_ADDR_ADDR_MASK) \
                                        >> 0 \
                                        | PDISPI_CMD_WR);
            break;
        case PDISPI_CMD_RD :
            *pFrame_p = (unsigned char) ((uwPayload_p & PDISPI_ADDR_ADDR_MASK) \
                                        >> 0 \
                                        | PDISPI_CMD_RD);
            break;
        case PDISPI_CMD_WRSQ :
            *pFrame_p = (unsigned char) ((uwPayload_p & PDISPI_ADDR_ADDR_MASK) \
                                        >> 0 \
                                        | PDISPI_CMD_WRSQ);
            break;
        case PDISPI_CMD_RDSQ :
            *pFrame_p = (unsigned char) ((uwPayload_p & PDISPI_ADDR_ADDR_MASK) \
                                        >> 0 \
                                        | PDISPI_CMD_RDSQ);
            break;
        case PDISPI_CMD_IDLE :
        default :
            *pFrame_p = (unsigned char) (0 | PDISPI_CMD_IDLE);
            break;
    }
    
    return iRet;
}
