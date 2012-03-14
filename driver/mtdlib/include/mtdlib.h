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

#ifndef _MTD_LIB_H_
#define _MTD_LIB_H_

#include "global.h"

//---------------------------------------------------------------------------
// const defines
//---------------------------------------------------------------------------

#define MTDLIB_STATE_DONE       0x00000001U  ///< master transfer is done
#define MTDLIB_STATE_BUSY       0x00000002U  ///< master transfer is in progress
#define MTDLIB_STATE_MASK       0x00000003U  ///< master state MASK

#define MTDLIB_CONTROL_WRITE    0x00000001U ///< master transfer write
#define MTDLIB_CONTROL_READ     0x00000002U ///< master transfer read
#define MTDLIB_CONTROL_BURST    0x00000004U ///< master transfer burst
#define MTDLIB_CONTROL_CONTI    0x00000008U ///< master transfer continuous
#define MTDLIB_CONTROL_MASK     0x0000000FU ///< master control MASK

#define MTDLIB_MAX_INSTANCES    16

//---------------------------------------------------------------------------
// types
//---------------------------------------------------------------------------

typedef struct
{
    int     m_iInstanceNumber; ///< number of master test device instances
    DWORD   m_audwBase[MTDLIB_MAX_INSTANCES]; ///< base addresses of master test device
} tMtdLibInitParam;

typedef struct
{
    DWORD   m_udwMin1stLatency; ///< minimum latency of first data arrival [ticks]
    DWORD   m_udwMax1stLatency; ///< maximum latency of first data arrival [ticks]
    DWORD   m_udwMinTransLength; ///< minimum Transfer Length [ticks]
    DWORD   m_udwMaxTransLength; ///< maximum Transfer Length [ticks]
} tMtdLibStatistic;

typedef enum
{
    mtdLibSuccessful    =   0x0000U,
    mtdLibError         =   0x0001U,
    mtdLibWrongRev      =   0x0002U,
    mtdLibHwInitError   =   0x0003U,
    mtdLibWrongParam    =   0x0004U,

} tMtdLibReturn;

//---------------------------------------------------------------------------
// function prototypes
//---------------------------------------------------------------------------

tMtdLibReturn mtdLibInit(tMtdLibInitParam InitParam_p);

tMtdLibReturn mtdLibSetTransferBaseAddress(int iInstanceNumber_p, DWORD udwTransferBase_p, int iNum_p);
tMtdLibReturn mtdLibSetTransferBurstSize(int iInstanceNumber_p, DWORD udwTransferBurst_p);
tMtdLibReturn mtdLibSetTransferType(int iInstanceNumber_p, DWORD udwTransferType_p);
tMtdLibReturn mtdLibSetTimeout(int iInstanceNumber_p, DWORD udwTimeout_p);

tMtdLibReturn mtdLibFire(int iInstanceNumber_p);
tMtdLibReturn mtdLibStop(int iInstanceNumber_p);

tMtdLibReturn mtdLibGetStatistic(int iInstanceNumber_p, tMtdLibStatistic *pStatistic_p);
tMtdLibReturn mtdLibResetStatistic(int iInstanceNumber_p);

#endif
