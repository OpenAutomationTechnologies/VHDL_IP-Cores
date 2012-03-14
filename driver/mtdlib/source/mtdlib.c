/****************************************************************************

  (c) Bernecker + Rainer Industrie-Elektronik Ges.m.b.H.
      A-5142 Eggelsberg, B&R Strasse 1
      www.br-automation.com


  Project:      HPMN Evaluation

  Description:  Library for Master Test Device

  License:

    Redistribution and use in source and binary forms, with or without
    modification, are permitted provided that the following conditions
    are met:

    1. Redistributions of source code must retain the above copyright
       notice, this list of conditions and the following disclaimer.

    2. Redistributions in binary form must reproduce the above copyright
       notice, this list of conditions and the following disclaimer in the
       documentation and/or other materials provided with the distribution.

    3. Neither the name of B&R nor the names of its
       contributors may be used to endorse or promote products derived
       from this software without prior written permission. For written
       permission, please contact office@br-automation.com.

    THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
    "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
    LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS
    FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE
    COPYRIGHT HOLDERS OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT,
    INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING,
    BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
    LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
    CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT
    LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN
    ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
    POSSIBILITY OF SUCH DAMAGE.

    Severability Clause:

        If a provision of this License is or becomes illegal, invalid or
        unenforceable in any jurisdiction, that shall not affect:
        1. the validity or enforceability in that jurisdiction of any other
           provision of this License; or
        2. the validity or enforceability in other jurisdictions of that or
           any other provision of this License.

  -------------------------------------------------------------------------
                $RCSfile$

                $Author$

                $Revision$  $Date$

                $State$

                Build Environment:
                    GCC V3.4

----------------------------------------------------------------------------*/

#include "mtdlib.h"
#include "string.h"
#if defined(__NIOS2__)
#include "io.h"
#elif defined(__MICROBLAZE__)
#include "xio.h"
#endif

//---------------------------------------------------------------------------
// const defines
//---------------------------------------------------------------------------

#define MTDLIB_REVISION         0x00000001U ///< mtdlib revision

#define MTDLIB_FIRE_PATTERN     0xAU ///< master fire pattern

#define MTDLIB_STATISTIC_MIN    0xFFFFFFFFU ///< initial/reset value of min latency
#define MTDLIB_STATISTIC_MAX    0x00000000U ///< initial/reser value of min latency

#if defined(__NIOS2__)
#define MTDLIB_IO_WR(addr, val) IOWR(addr, 0, val)
#define MTDLIB_IO_RD(addr)      IORD(addr, 0)
#elif defined(__MICROBLAZE__)
#define MTDLIB_IO_WR(addr, val) XIo_Out32(addr, val)
#define MTDLIB_IO_RD(addr)      XIo_In32(addr)
#endif

#define MTDLIB_BASEADDR_CNT     2

//---------------------------------------------------------------------------
// types
//---------------------------------------------------------------------------

struct sMtdLibSlaveInterface
{
    DWORD                   m_dwRevision; ///< revision number (RO)
    DWORD                   m_dwTimeTick; ///< time tick [ticks] (RO)
    DWORD                   m_dwState; ///< ip-core state (RO)
    DWORD                   m_dwControl; ///< ip-core control (RW)
    DWORD                   m_dwFire; ///< fire pattern (RW)
    DWORD                   m_dwBaseAddress[MTDLIB_BASEADDR_CNT]; ///< transfer base addresses (RW)
    DWORD                   m_dwBurstSize; ///< transfer burst size (RW)
    DWORD                   m_dwTimeout; ///< timeout between continuous transfers (RW)
    tMtdLibStatistic        m_Statistic; ///< statistic values (RO)
} __attribute__((packed));

typedef struct sMtdLibSlaveInterface tMtdLibSlaveInterface;

typedef struct
{
    volatile tMtdLibSlaveInterface   *m_pSlaveInterface; ///< slave interface access

} tMtdLibInstance;

static tMtdLibInstance aInstances[MTDLIB_MAX_INSTANCES];

//---------------------------------------------------------------------------
// public function
//---------------------------------------------------------------------------

/**
********************************************************************************
\brief  initializes master test device library

~~~~

\param  InitParam_p         initialization parameters

\retval ret         mtdLibSuccessful if no error
                    mtdLibError if ip-core not found
                    mtdLibWrongRev if wrong revision
*******************************************************************************/
tMtdLibReturn mtdLibInit(tMtdLibInitParam InitParam_p)
{
    int i;
    tMtdLibReturn ret = mtdLibSuccessful;

    //clear instance
    memset(&aInstances[0], 0, sizeof(aInstances));

    for(i=0; i<InitParam_p.m_iInstanceNumber; i++)
    {
        //set interface pointer
        aInstances[i].m_pSlaveInterface = (tMtdLibSlaveInterface*)InitParam_p.m_audwBase[i];

        //check revision
        if(MTDLIB_IO_RD(&(aInstances[i].m_pSlaveInterface->m_dwRevision)) == MTDLIB_REVISION)
        {
            //revision correct
        }
        else
        {
            ret = mtdLibWrongRev;
            goto exit;
        }

        //reset registers and verify if this has an effect
        MTDLIB_IO_WR(&(aInstances[i].m_pSlaveInterface->m_dwFire), 0); //reset fire to zero
        MTDLIB_IO_WR(&(aInstances[i].m_pSlaveInterface->m_dwControl), 0); //reset all control bits
        MTDLIB_IO_WR(&(aInstances[i].m_pSlaveInterface->m_dwState), MTDLIB_STATE_MASK); //reset with a one
        MTDLIB_IO_WR(&(aInstances[i].m_pSlaveInterface->m_Statistic.m_udwMin1stLatency), 0); //write any to reset
        MTDLIB_IO_WR(&(aInstances[i].m_pSlaveInterface->m_Statistic.m_udwMax1stLatency), 0); //write any to reset
        MTDLIB_IO_WR(&(aInstances[i].m_pSlaveInterface->m_Statistic.m_udwMinTransLength), 0); //write any to reset
        MTDLIB_IO_WR(&(aInstances[i].m_pSlaveInterface->m_Statistic.m_udwMaxTransLength), 0); //write any to reset

        //check fire
        if(MTDLIB_IO_RD(&(aInstances[i].m_pSlaveInterface->m_dwFire)) != 0)
        {
            ret = mtdLibHwInitError;
            goto exit;
        }

        //check control
        if(MTDLIB_IO_RD(&(aInstances[i].m_pSlaveInterface->m_dwControl)) != 0)
        {
            ret = mtdLibHwInitError;
            goto exit;
        }

        //check state
        if(MTDLIB_IO_RD(&(aInstances[i].m_pSlaveInterface->m_dwState)) != 0)
        {
            ret = mtdLibHwInitError;
            goto exit;
        }

        //check statistics
        if(MTDLIB_IO_RD(&(aInstances[i].m_pSlaveInterface->m_Statistic.m_udwMin1stLatency)) != MTDLIB_STATISTIC_MIN)
        {
            ret = mtdLibHwInitError;
            goto exit;
        }
        else if(MTDLIB_IO_RD(&(aInstances[i].m_pSlaveInterface->m_Statistic.m_udwMax1stLatency)) != MTDLIB_STATISTIC_MAX)
        {
            ret = mtdLibHwInitError;
            goto exit;
        }
    }

exit:
    return ret;
}

/**
********************************************************************************
\brief  set transfer base/start address

~~~~

\param  iInstanceNumber_p         instance number of master test device (0 .. 15)
\param  udwTransferBase_p         transfer base/start address
\param  iNum_p                    number of base address (1 .. 2)

\retval ret         mtdLibSuccessful if no error

*******************************************************************************/
tMtdLibReturn mtdLibSetTransferBaseAddress(int iInstanceNumber_p, DWORD udwTransferBase_p, int iNum_p)
{
    tMtdLibReturn ret = mtdLibSuccessful;

    if(iNum_p > MTDLIB_BASEADDR_CNT)
    {
        ret = mtdLibWrongParam;
        goto exit;
    }

    MTDLIB_IO_WR(&(aInstances[iInstanceNumber_p].m_pSlaveInterface->m_dwBaseAddress[iNum_p-1]), udwTransferBase_p);

    if(MTDLIB_IO_RD(&(aInstances[iInstanceNumber_p].m_pSlaveInterface->m_dwBaseAddress[iNum_p-1])) != udwTransferBase_p)
    {
        ret = mtdLibHwInitError;
    }

exit:
    return ret;
}

/**
********************************************************************************
\brief  set transfer burst size

~~~~

\param  iInstanceNumber_p         instance number of master test device (0 .. 15)
\param  udwTransferBurst_p         transfer burst size (in transfer words)

\retval ret         mtdLibSuccessful if no error

*******************************************************************************/
tMtdLibReturn mtdLibSetTransferBurstSize(int iInstanceNumber_p, DWORD udwTransferBurst_p)
{
    tMtdLibReturn ret = mtdLibSuccessful;

    MTDLIB_IO_WR(&(aInstances[iInstanceNumber_p].m_pSlaveInterface->m_dwBurstSize), udwTransferBurst_p);

//value is masked depending on burst capability!
//    if(MTDLIB_IO_RD(&(mtdLibInstance_l.m_pSlaveInterface->m_dwBurstSize)) != udwTransferBurst_p)
//    {
//        ret = mtdLibHwInitError;
//    }

    return ret;
}

/**
********************************************************************************
\brief  set type of transfer

~~~~

\param  iInstanceNumber_p         instance number of master test device (0 .. 15)
\param  udwTransferType_p         define type of transfer

\retval ret         mtdLibSuccessful if no error

*******************************************************************************/
tMtdLibReturn mtdLibSetTransferType(int iInstanceNumber_p, DWORD udwTransferType_p)
{
    tMtdLibReturn ret = mtdLibSuccessful;

    if((udwTransferType_p & MTDLIB_CONTROL_WRITE) && (udwTransferType_p & MTDLIB_CONTROL_READ))
    {
        ret = mtdLibWrongParam;
        goto exit;
    }

    MTDLIB_IO_WR(&(aInstances[iInstanceNumber_p].m_pSlaveInterface->m_dwControl), udwTransferType_p & \
            MTDLIB_CONTROL_MASK);

    if(MTDLIB_IO_RD(&(aInstances[iInstanceNumber_p].m_pSlaveInterface->m_dwControl)) != (udwTransferType_p & \
            MTDLIB_CONTROL_MASK))
    {
        ret = mtdLibHwInitError;
    }

exit:
    return ret;
}

/**
********************************************************************************
\brief  set timeout between continuous transfers

~~~~

\param  iInstanceNumber_p         instance number of master test device (0 .. 15)
\param  udwTimeout_p         timeout in ticks

\retval ret         mtdLibSuccessful if no error

*******************************************************************************/
tMtdLibReturn mtdLibSetTimeout(int iInstanceNumber_p, DWORD udwTimeout_p)
{
    tMtdLibReturn ret = mtdLibSuccessful;

    MTDLIB_IO_WR(&(aInstances[iInstanceNumber_p].m_pSlaveInterface->m_dwTimeout), udwTimeout_p);

    if(MTDLIB_IO_RD(&(aInstances[iInstanceNumber_p].m_pSlaveInterface->m_dwTimeout)) != udwTimeout_p)
    {
        ret = mtdLibHwInitError;
    }

    return ret;
}

/**
********************************************************************************
\brief  start transfer

~~~~

\param  iInstanceNumber_p         instance number of master test device (0 .. 15)

\retval ret         mtdLibSuccessful if no error

*******************************************************************************/
tMtdLibReturn mtdLibFire(int iInstanceNumber_p)
{
    tMtdLibReturn ret = mtdLibSuccessful;

    MTDLIB_IO_WR(&(aInstances[iInstanceNumber_p].m_pSlaveInterface->m_dwFire), MTDLIB_FIRE_PATTERN);

    if(MTDLIB_IO_RD(&(aInstances[iInstanceNumber_p].m_pSlaveInterface->m_dwFire)) != MTDLIB_FIRE_PATTERN)
    {
        ret = mtdLibHwInitError;
    }

    return ret;
}

/**
********************************************************************************
\brief  stop transfer

~~~~

\param  iInstanceNumber_p         instance number of master test device (0 .. 15)

\retval ret         mtdLibSuccessful if no error

*******************************************************************************/
tMtdLibReturn mtdLibStop(int iInstanceNumber_p)
{
    tMtdLibReturn ret = mtdLibSuccessful;

    MTDLIB_IO_WR(&(aInstances[iInstanceNumber_p].m_pSlaveInterface->m_dwFire), 0);

    if(MTDLIB_IO_RD(&(aInstances[iInstanceNumber_p].m_pSlaveInterface->m_dwFire)) != 0)
    {
        ret = mtdLibHwInitError;
    }

    return ret;
}

/**
********************************************************************************
\brief  get statistic

~~~~

\param  iInstanceNumber_p         instance number of master test device (0 .. 15)
\param  pStatistic_p         pointer to statistic memory space

\retval ret         mtdLibSuccessful if no error

*******************************************************************************/
tMtdLibReturn mtdLibGetStatistic(int iInstanceNumber_p, tMtdLibStatistic *pStatistic_p)
{
    tMtdLibReturn ret = mtdLibSuccessful;


    memcpy((void*)pStatistic_p, \
            (void*)&(aInstances[iInstanceNumber_p].m_pSlaveInterface->m_Statistic), \
            sizeof(aInstances[iInstanceNumber_p].m_pSlaveInterface->m_Statistic));

    return ret;
}

/**
********************************************************************************
\brief  reset statistic

~~~~

\param  iInstanceNumber_p         instance number of master test device (0 .. 15)

\retval ret         mtdLibSuccessful if no error

*******************************************************************************/
tMtdLibReturn mtdLibResetStatistic(int iInstanceNumber_p)
{
    tMtdLibReturn ret = mtdLibSuccessful;

    MTDLIB_IO_WR(&(aInstances[iInstanceNumber_p].m_pSlaveInterface->m_Statistic.m_udwMax1stLatency), 0);

    MTDLIB_IO_WR(&(aInstances[iInstanceNumber_p].m_pSlaveInterface->m_Statistic.m_udwMin1stLatency), 0);

    MTDLIB_IO_WR(&(aInstances[iInstanceNumber_p].m_pSlaveInterface->m_Statistic.m_udwMaxTransLength), 0);

    MTDLIB_IO_WR(&(aInstances[iInstanceNumber_p].m_pSlaveInterface->m_Statistic.m_udwMinTransLength), 0);

    return ret;
}
