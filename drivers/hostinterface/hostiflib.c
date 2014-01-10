/**
********************************************************************************
\file   hostiflib.c

\brief  Host Interface Library - High Level Driver Implementation

The file contains the high level driver for the host interface library.

\ingroup module_hostiflib
*******************************************************************************/

/*------------------------------------------------------------------------------
Copyright (c) 2012, Bernecker+Rainer Industrie-Elektronik Ges.m.b.H. (B&R)
All rights reserved.

Redistribution and use in source and binary forms, with or without
modification, are permitted provided that the following conditions are met:
    * Redistributions of source code must retain the above copyright
      notice, this list of conditions and the following disclaimer.
    * Redistributions in binary form must reproduce the above copyright
      notice, this list of conditions and the following disclaimer in the
      documentation and/or other materials provided with the distribution.
    * Neither the name of the copyright holders nor the
      names of its contributors may be used to endorse or promote products
      derived from this software without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
DISCLAIMED. IN NO EVENT SHALL COPYRIGHT HOLDERS BE LIABLE FOR ANY
DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
(INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
(INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
------------------------------------------------------------------------------*/

/**
********************************************************************************
\defgroup   module_hostiflib    Host Interface Library
\ingroup    libraries

The host interface library provides a software interface for using the host
interface IP core. It provides several features like queues and linear memory
modules.
*******************************************************************************/

//------------------------------------------------------------------------------
// includes
//------------------------------------------------------------------------------
#include "hostiflib_l.h"
#include "hostiflib.h"
#include "hostiflib_target.h"

#include <stdlib.h>
#include <string.h>

//============================================================================//
//            G L O B A L   D E F I N I T I O N S                             //
//============================================================================//

//------------------------------------------------------------------------------
// const defines
//------------------------------------------------------------------------------

//------------------------------------------------------------------------------
// module global vars
//------------------------------------------------------------------------------

//------------------------------------------------------------------------------
// global function prototypes
//------------------------------------------------------------------------------

//============================================================================//
//            P R I V A T E   D E F I N I T I O N S                           //
//============================================================================//

//------------------------------------------------------------------------------
// const defines
//------------------------------------------------------------------------------

#define HOSTIF_MAGIC              0x504C4B00  ///< Host Interface Magic

#define HOSTIF_INSTANCE_COUNT       2   ///< number of supported instances

//------------------------------------------------------------------------------
// local types
//------------------------------------------------------------------------------

/**
\brief Version field in Status/Control - Information

Used to obtain hardware/software mismatch
*/
typedef struct sHostifHwVersion
{
    UINT8           cnt;        ///< Counting field
    tHostifVersion  version;    ///< Version field
} tHostifHwVersion;

/**
\brief Buffer descriptor structure

This structure is used to store the buffer descriptors
*/
typedef struct sHostifBufDesc
{
    UINT32  offset;     ///< Buffer offset within hostif
    UINT    span;       ///< Buffer span [byte]
} tHostifBufDesc;

/**
\brief Buffer map structure

This structure is used to store the buffer base address and size.
*/
typedef struct sHostifBufMap
{
    UINT8*  pBase;  ///< Buffer base address
    UINT    span;   ///< Buffer span [byte]
} tHostifBufMap;

/**
\brief Initialization Parameter structure

This structure is used to forward the initialization from Pcp to host.
*/
typedef struct sHostifInitParam
{
    UINT32          initMemLength; ///< Length of aInitMem
    tHostifBufDesc  aInitMem[HOSTIF_DYNBUF_COUNT + HOSTIF_BUF_COUNT]; ///< Memory map from hostiflib-mem.h
    UINT8           aUser[HOSTIF_USER_INIT_PAR_SIZE]; ///< Space for higher layers
} tHostifInitParam;

/**
\brief Host Interface Instance

Holds the configuration passed to the instance at creation.
*/
typedef struct sHostif
{
    tHostifConfig       config; ///< copy of configuration
    UINT8*              pBase;  ///< base address of host interface
    tHostifIrqCb        apfnIrqCb[kHostifIrqSrcLast]; ///< table that stores the irq callbacks
    tHostifBufMap       aBufMap[kHostifInstIdLast]; ///< Table storing buffer mapping
#if CONFIG_HOSTIF_PCP != FALSE
    tHostifInitParam*   pInitParam; ///< Initialization parameter
#else
    UINT8*             apDynBuf[HOSTIF_DYNBUF_COUNT];
#endif
} tHostif;

//------------------------------------------------------------------------------
// local vars
//------------------------------------------------------------------------------
/**
\brief Instance array

This array holds all Host Interface instances available.
*/
static tHostif *paHostifInstance_l[HOSTIF_INSTANCE_COUNT] =
{
    NULL
};

//------------------------------------------------------------------------------
// local function prototypes
//------------------------------------------------------------------------------
/* Local functions for Pcp and Host */
static void freePtr(void *p);
static tHostifReturn checkMagic (UINT8* pBase_p);
static tHostifReturn checkVersion (UINT8* pBase_p, tHostifVersion* pSwVersion_p);

#if CONFIG_HOSTIF_PCP != FALSE

/* Local functions for Pcp only */
static tHostifReturn controlBridge (tHostif *pHostif_p, BOOL fEnable_p);

#else

/* Local functions for Host only */
static void hostifIrqHandler (void *pArg_p);
static tHostifReturn controlIrqMaster (tHostif *pHostif_p, BOOL fEnable_p);
HOSTIF_INLINE static BOOL getBridgeEnabled (tHostif *pHostif_p);

#endif

//============================================================================//
//            P U B L I C   F U N C T I O N S                                 //
//============================================================================//

//------------------------------------------------------------------------------
/**
\brief  Create a host interface instance

This function creates a host interface instance, and initializes it depending
on the pConfig_p parameters.

\param  pConfig_p               The caller provides the configuration
                                parameters with this pointer.
\param  ppInstance_p            The function returns with this double-pointer
                                the created instance pointer. (return)

\return The function returns a tHostifReturn error code.
\retval kHostifSuccessful       The host interface is configured successfully
                                with the provided parameters.
\retval kHostifInvalidParameter The caller has provided incorrect parameters.
\retval kHostifNoResource       Heap allocation was impossible or to many
                                instances are present.
\retval kHostifWrongMagic       Can't find a valid host interface (invalid
                                magic).
\retval kHostifWrongVersion     The version fields in hardware mismatches those
                                in software.

\ingroup module_hostiflib
*/
//------------------------------------------------------------------------------
tHostifReturn hostif_create (tHostifConfig *pConfig_p, tHostifInstance *ppInstance_p)
{
    tHostifReturn   Ret = kHostifSuccessful;
    tHostif*        pHostif = NULL;
    UINT8*          pBase_p = NULL;
    int i;

    if(pConfig_p == NULL || ppInstance_p == NULL)
    {
        Ret = kHostifInvalidParameter;
        goto Exit;
    }

    pBase_p = HOSTIF_MAKE_NONCACHEABLE(pConfig_p->pBase);

    // check magic
    Ret = checkMagic(pBase_p);

    if(Ret != kHostifSuccessful)
    {
        goto Exit;
    }

    // check version
    Ret = checkVersion(pBase_p, &pConfig_p->version);

    if(Ret != kHostifSuccessful)
    {
        goto Exit;
    }

    // create instance
    pHostif = (tHostif*)malloc(sizeof(tHostif));

    if(pHostif == NULL)
    {
        Ret = kHostifNoResource;
        goto Exit;
    }

    memset(pHostif, 0, sizeof(tHostif));

    // initialize instance
    pHostif->config = *pConfig_p;

    // store hostif base
    pHostif->pBase = HOSTIF_MAKE_NONCACHEABLE(pHostif->config.pBase);

    // store instance in array
    for(i=0; i<HOSTIF_INSTANCE_COUNT; i++)
    {
        if(paHostifInstance_l[i] == NULL)
        {
            // free entry found
            paHostifInstance_l[i] = pHostif;

            break;
        }
    }

    if(i == HOSTIF_INSTANCE_COUNT)
    {
        Ret = kHostifNoResource;
        goto Exit;
    }


#if CONFIG_HOSTIF_PCP != FALSE
    {
        tHostifBufDesc aInitVec[] = HOSTIF_INIT_VEC;

        // Allocate init parameter memory
        pHostif->pInitParam = (tHostifInitParam*)HOSTIF_UNCACHED_MALLOC(sizeof(tHostifInitParam));

        if(pHostif->pInitParam == NULL)
        {
            Ret = kHostifNoResource;
            goto Exit;
        }

        memset(pHostif->pInitParam, 0, sizeof(tHostifInitParam));

        // Initialize init parameter memory
        pHostif->pInitParam->initMemLength = HOSTIF_DYNBUF_COUNT + HOSTIF_BUF_COUNT;
        memcpy(pHostif->pInitParam->aInitMem, aInitVec, sizeof(aInitVec));

        // Now set init parameter address to hostif
        hostif_writeInitBase(pHostif->pBase, (UINT32)pHostif->pInitParam);

        // Write span of buffers into buf map table, malloc them and write to hostif
        for(i=0; i<kHostifInstIdLast; i++)
        {
            pHostif->aBufMap[i].span = aInitVec[i + HOSTIF_DYNBUF_COUNT].span;
            pHostif->aBufMap[i].pBase = (UINT8*)HOSTIF_UNCACHED_MALLOC(pHostif->aBufMap[i].span);

            if(pHostif->aBufMap[i].pBase == NULL)
            {
                Ret = kHostifNoResource;
                goto Exit;
            }

            hostif_writeBufPcp(pHostif->pBase, i, (UINT32)pHostif->aBufMap[i].pBase);
        }
    }
#else
    {
        UINT32              pcpAddr;
        tHostifInitParam*   pInitParam;

        // Busy wait for enabled bridge
        while(getBridgeEnabled(pHostif) == FALSE)
        {
            //jz Use timeout?
        }

        // Get init param address in pcp memory space and write it to dyn buf 0
        pcpAddr = hostif_readInitBase(pHostif->pBase);
        hostif_writeDynBufHost(pHostif->pBase, 0, pcpAddr);

        // Point to address after status control registers (=dyn buf 0)
        pInitParam = (tHostifInitParam*)(pHostif->pBase + HOSTIF_STCTRL_SPAN);

        // Check if mem length is correct, otherwise version mismatch!
        if(pInitParam->initMemLength != HOSTIF_DYNBUF_COUNT + HOSTIF_BUF_COUNT)
        {
            Ret = kHostifWrongVersion;
            goto Exit;
        }

        // And now, get the stuff
        for(i=0; i<pInitParam->initMemLength; i++)
        {
            pHostif->aBufMap[i].pBase = pHostif->pBase + pInitParam->aInitMem[i].offset;
            pHostif->aBufMap[i].span = pInitParam->aInitMem[i].span;
        }
    }
#endif

#if CONFIG_HOSTIF_PCP != FALSE
    // since everything is fine, activate bridge
    Ret = controlBridge(pHostif, TRUE);

    if(Ret != kHostifSuccessful)
    {
        goto Exit;
    }
#endif

#if CONFIG_HOSTIF_PCP == FALSE
    // register isr in system
    if(HOSTIF_IRQ_REG(hostifIrqHandler, (void*)pHostif))
    {
        Ret = kHostifNoResource;
        goto Exit;
    }

    // enable system irq
    HOSTIF_IRQ_ENABLE();
#endif

    // return instance pointer
    *ppInstance_p = pHostif;

Exit:
    if(Ret != kHostifSuccessful)
    {
        hostif_delete(pHostif);
    }

    return Ret;
}

//------------------------------------------------------------------------------
/**
\brief  Delete host interface instance

This function deletes a host interface instance.

\param  pInstance_p             The host interface instance that should be
                                deleted

\return The function returns a tHostifReturn error code.
\retval kHostifSuccessful       The host interface is deleted successfully.
\retval kHostifInvalidParameter The caller has provided incorrect parameters.
\retval kHostifHwWriteError     Deactivation of hardware is faulty.

\ingroup module_hostiflib
*/
//------------------------------------------------------------------------------
tHostifReturn hostif_delete (tHostifInstance pInstance_p)
{
    tHostifReturn Ret = kHostifSuccessful;
    tHostif *pHostif = (tHostif*)pInstance_p;
    int i;

    if(pInstance_p == NULL)
    {
        Ret = kHostifInvalidParameter;
        goto Exit;
    }

#if CONFIG_HOSTIF_PCP == FALSE
    // enable system irq (ignore ret)
    HOSTIF_IRQ_DISABLE();

    // degister isr in system (ignore ret)
    HOSTIF_IRQ_REG(NULL, NULL);
#endif

    // delete instance in instance array
    for(i=0; i<HOSTIF_INSTANCE_COUNT; i++)
    {
        if(pHostif == paHostifInstance_l[i])
        {
            paHostifInstance_l[i] = NULL;

            break;
        }
    }

#if CONFIG_HOSTIF_PCP != FALSE
    // deactivate bridge (ignore ret)
    Ret = controlBridge(pHostif, FALSE);

    // Free init parameter
    if(pHostif->pInitParam != NULL)
    {
        HOSTIF_UNCACHED_FREE(pHostif->pInitParam);
    }

    hostif_writeInitBase(pHostif->pBase, (UINT32)NULL);

    // Free buffers
    for(i=0; i<kHostifInstIdLast; i++)
    {
        if(pHostif->aBufMap[i].pBase != NULL)
        {
            HOSTIF_UNCACHED_FREE(pHostif->aBufMap[i].pBase);
        }

        hostif_writeBufPcp(pHostif->pBase, i, (UINT32)NULL);
    }
#endif

    freePtr(pHostif);

Exit:
    return Ret;
}

//------------------------------------------------------------------------------
/**
\brief  Returns the instance of the given processor instance

If the instance is not found NULL is returned.

\param  Instance_p              Processor instance

\return The function returns an host interface instance.
\retval NULL                    Host interface instance not found

\ingroup module_hostiflib
*/
//------------------------------------------------------------------------------
tHostifInstance hostif_getInstance (UINT Instance_p)
{
    tHostifInstance pHostif = NULL;
    int i;

    // search through array and return the matching one
    for(i=0; i<HOSTIF_INSTANCE_COUNT; i++)
    {
        if(paHostifInstance_l[i]->config.instanceNum == Instance_p)
        {
            pHostif = (tHostifInstance)paHostifInstance_l[i];

            break;
        }
    }

    return pHostif;
}

//------------------------------------------------------------------------------
/**
\brief  This function adds an irq handler for the corresponding irq source

This function adds an irq handler function for the corresponding irq source.
Note: The provided callback is invoked within the interrupt context!
If the provided callback is NULL, then the irq source is disabled.

\param  pInstance_p             Host interface instance
\param  irqSrc_p                Irq source that should invoke the callback
\param  pfnCb_p                 Callback function that is invoked

\return The function returns a tHostifReturn error code.
\retval kHostifSuccessful       The process function exit without errors.
\retval kHostifInvalidParameter The caller has provided incorrect parameters.

\ingroup module_hostiflib
*/
//------------------------------------------------------------------------------
#if CONFIG_HOSTIF_PCP == FALSE
tHostifReturn hostif_irqRegHdl (tHostifInstance pInstance_p,
        tHostifIrqSrc irqSrc_p, tHostifIrqCb pfnCb_p)
{
    tHostifReturn Ret = kHostifSuccessful;
    tHostif *pHostif = (tHostif*)pInstance_p;
    UINT16 irqEnableVal;

    if(pInstance_p == NULL || irqSrc_p >= kHostifIrqSrcLast)
    {
        Ret = kHostifInvalidParameter;
        goto Exit;
    }

    // get irq source enable from hw
    irqEnableVal = hostif_readIrqEnable(pHostif->pBase);

    // enable irq source if callback is not NULL
    if(pfnCb_p != NULL)
        irqEnableVal |= (1 << irqSrc_p);
    else
        irqEnableVal &= ~(1 << irqSrc_p);

    // store callback in instance
    pHostif->apfnIrqCb[irqSrc_p] = pfnCb_p;

    // write irq source enable back to hw
    hostif_writeIrqEnable(pHostif->pBase, irqEnableVal);

Exit:
    return Ret;
}
#endif

//------------------------------------------------------------------------------
/**
\brief  This function enables an irq source

This function enables an irq source from the Pcp side.

\param  pInstance_p             host interface instance
\param  irqSrc_p                irq source to be controlled
\param  fEnable_p               enable the irq source (TRUE)

\return The function returns a tHostifReturn error code.
\retval kHostifSuccessful       The process function exit without errors.
\retval kHostifInvalidParameter The caller has provided incorrect parameters.

\ingroup module_hostiflib
*/
//------------------------------------------------------------------------------
#if CONFIG_HOSTIF_PCP != FALSE
tHostifReturn hostif_irqSourceEnable (tHostifInstance pInstance_p,
        tHostifIrqSrc irqSrc_p, BOOL fEnable_p)
{
    tHostifReturn Ret = kHostifSuccessful;
    tHostif *pHostif = (tHostif*)pInstance_p;
    UINT16 irqEnableVal;

    if(pInstance_p == NULL || irqSrc_p >= kHostifIrqSrcLast)
    {
        Ret = kHostifInvalidParameter;
        goto Exit;
    }

    // get irq source enable from hw
    irqEnableVal = hostif_readIrqEnable(pHostif->pBase);

    if(fEnable_p != FALSE)
        irqEnableVal |= (1 << irqSrc_p);
    else
        irqEnableVal &= ~(1 << irqSrc_p);

    // write irq source enable back to hw
    hostif_writeIrqEnable(pHostif->pBase, irqEnableVal);

Exit:
    return Ret;
}
#endif

//------------------------------------------------------------------------------
/**
\brief  This function controls the master irq enable

This function allows the host to enable or disable all irq sources from the
host interface.

\param  pInstance_p             host interface instance
\param  fEnable_p               enable the master irq (TRUE)

\return The function returns a tHostifReturn error code.
\retval kHostifSuccessful       The process function exit without errors.
\retval kHostifInvalidParameter The caller has provided incorrect parameters.

\ingroup module_hostiflib
*/
//------------------------------------------------------------------------------
#if CONFIG_HOSTIF_PCP == FALSE
tHostifReturn hostif_irqMasterEnable (tHostifInstance pInstance_p,
        BOOL fEnable_p)
{
    tHostifReturn Ret = kHostifSuccessful;
    tHostif *pHostif = pInstance_p;

    if(pInstance_p == NULL)
    {
        Ret = kHostifInvalidParameter;
        goto Exit;
    }

    // activte master irq enable
    Ret = controlIrqMaster(pHostif, fEnable_p);

    if(Ret != kHostifSuccessful)
    {
        goto Exit;
    }

Exit:
    return Ret;
}
#endif

//------------------------------------------------------------------------------
/**
\brief  This function sets a command to the host interface

\param  pInstance_p             host interface instance
\param  cmd_p                   command

\return The function returns a tHostifReturn error code.
\retval kHostifSuccessful       The process function exit without errors.
\retval kHostifInvalidParameter The caller has provided incorrect parameters.

\ingroup module_hostiflib
*/
//------------------------------------------------------------------------------
tHostifReturn hostif_setCommand (tHostifInstance pInstance_p, tHostifCommand cmd_p)
{
    tHostifReturn Ret = kHostifSuccessful;
    tHostif *pHostif = (tHostif*)pInstance_p;

    if(pInstance_p == NULL)
    {
        Ret = kHostifInvalidParameter;
        goto Exit;
    }

    hostif_writeCommand(pHostif->pBase, cmd_p);

Exit:
    return Ret;
}

//------------------------------------------------------------------------------
/**
\brief  This function gets a command from the host interface

\param  pInstance_p             host interface instance
\param  pCmd_p                  command

\return The function returns a tHostifReturn error code.
\retval kHostifSuccessful       The process function exit without errors.
\retval kHostifInvalidParameter The caller has provided incorrect parameters.

\ingroup module_hostiflib
*/
//------------------------------------------------------------------------------
tHostifReturn hostif_getCommand (tHostifInstance pInstance_p, tHostifCommand *pCmd_p)
{
    tHostifReturn Ret = kHostifSuccessful;
    tHostif *pHostif = (tHostif*)pInstance_p;

    if(pInstance_p == NULL || pCmd_p == NULL)
    {
        Ret = kHostifInvalidParameter;
        goto Exit;
    }

    *pCmd_p = hostif_readCommand(pHostif->pBase);

Exit:
    return Ret;
}

//------------------------------------------------------------------------------
/**
\brief  This function sets a state to the host interface

Note that only the Pcp is allowed to write to this register!

\param  pInstance_p             host interface instance
\param  sta_p                   state

\return The function returns a tHostifReturn error code.
\retval kHostifSuccessful       The process function exit without errors.
\retval kHostifInvalidParameter The caller has provided incorrect parameters.

\ingroup module_hostiflib
*/
//------------------------------------------------------------------------------
#if CONFIG_HOSTIF_PCP != FALSE
tHostifReturn hostif_setState (tHostifInstance pInstance_p, tHostifState sta_p)
{
    tHostifReturn Ret = kHostifSuccessful;
    tHostif *pHostif = (tHostif*)pInstance_p;

    if(pInstance_p == NULL)
    {
        Ret = kHostifInvalidParameter;
        goto Exit;
    }

    hostif_writeState(pHostif->pBase, sta_p);

Exit:
    return Ret;
}
#endif

//------------------------------------------------------------------------------
/**
\brief  This function gets the state from the host interface

\param  pInstance_p             host interface instance
\param  pSta_p                  state

\return The function returns a tHostifReturn error code.
\retval kHostifSuccessful       The process function exit without errors.
\retval kHostifInvalidParameter The caller has provided incorrect parameters.

\ingroup module_hostiflib
*/
//------------------------------------------------------------------------------
tHostifReturn hostif_getState (tHostifInstance pInstance_p, tHostifState *pSta_p)
{
    tHostifReturn Ret = kHostifSuccessful;
    tHostif *pHostif = (tHostif*)pInstance_p;

    if(pInstance_p == NULL || pSta_p == NULL)
    {
        Ret = kHostifInvalidParameter;
        goto Exit;
    }

    *pSta_p = hostif_readState(pHostif->pBase);

Exit:
    return Ret;
}

//------------------------------------------------------------------------------
/**
\brief  This function sets an error/return to the host interface

Note that only the Pcp is allowed to write to this register!

\param  pInstance_p             host interface instance
\param  err_p                   error/return code

\return The function returns a tHostifReturn error code.
\retval kHostifSuccessful       The process function exit without errors.
\retval kHostifInvalidParameter The caller has provided incorrect parameters.

\ingroup module_hostiflib
*/
//------------------------------------------------------------------------------
tHostifReturn hostif_setError (tHostifInstance pInstance_p, tHostifError err_p)
{
    tHostifReturn Ret = kHostifSuccessful;
    tHostif *pHostif = (tHostif*)pInstance_p;

    if(pInstance_p == NULL)
    {
        Ret = kHostifInvalidParameter;
        goto Exit;
    }

    hostif_writeReturn(pHostif->pBase, err_p);

Exit:
    return Ret;
}

//------------------------------------------------------------------------------
/**
\brief  This function gets the error/return from the host interface

\param  pInstance_p             host interface instance
\param  pErr_p                  error/return

\return The function returns a tHostifReturn error code.
\retval kHostifSuccessful       The process function exit without errors.
\retval kHostifInvalidParameter The caller has provided incorrect parameters.

\ingroup module_hostiflib
*/
//------------------------------------------------------------------------------
tHostifReturn hostif_getError (tHostifInstance pInstance_p, tHostifError *pErr_p)
{
    tHostifReturn Ret = kHostifSuccessful;
    tHostif *pHostif = (tHostif*)pInstance_p;

    if(pInstance_p == NULL || pErr_p == NULL)
    {
        Ret = kHostifInvalidParameter;
        goto Exit;
    }

    *pErr_p = hostif_readReturn(pHostif->pBase);

Exit:
    return Ret;
}

//------------------------------------------------------------------------------
/**
\brief  This function sets the heart beat value to the host interface

Note that only the Pcp is allowed to write to this register!

\param  pInstance_p             Host interface instance
\param  heartbeat_p             Heart beat value

\return The function returns a tHostifReturn error code.
\retval kHostifSuccessful       The process function exit without errors.
\retval kHostifInvalidParameter The caller has provided incorrect parameters.
\retval kHostifWrongProcInst    The caller processor instance is not allowed.

\ingroup module_hostiflib
*/
//------------------------------------------------------------------------------
#if CONFIG_HOSTIF_PCP != FALSE
tHostifReturn hostif_setHeartbeat (tHostifInstance pInstance_p, UINT16 heartbeat_p)
{
    tHostifReturn Ret = kHostifSuccessful;
    tHostif *pHostif = (tHostif*)pInstance_p;

    if(pInstance_p == NULL)
    {
        Ret = kHostifInvalidParameter;
        goto Exit;
    }

    hostif_writeHeartbeat(pHostif->pBase, heartbeat_p);

Exit:
    return Ret;
}
#endif

//------------------------------------------------------------------------------
/**
\brief  This function gets the heart beat value from the host interface

\param  pInstance_p             Host interface instance
\param  pHeartbeat_p            Heart beat value

\return The function returns a tHostifReturn error code.
\retval kHostifSuccessful       The process function exit without errors.
\retval kHostifInvalidParameter The caller has provided incorrect parameters.

\ingroup module_hostiflib
*/
//------------------------------------------------------------------------------
tHostifReturn hostif_getHeartbeat (tHostifInstance pInstance_p, UINT16 *pHeartbeat_p)
{
    tHostifReturn Ret = kHostifSuccessful;
    tHostif *pHostif = (tHostif*)pInstance_p;

    if(pInstance_p == NULL || pHeartbeat_p == NULL)
    {
        Ret = kHostifInvalidParameter;
        goto Exit;
    }

    *pHeartbeat_p = hostif_readHeartbeat(pHostif->pBase);

Exit:
    return Ret;
}

//------------------------------------------------------------------------------
/**
\brief  This function acquires a dynamic buffer for the host

\param  pInstance_p             Host interface instance
\param  pcpBaseAddr_p           Address in pcp memory space
\param  pInstId_p               Returns dynamic buffer instance being acquired (needed for freeing)
\param  ppBufBase_p             Addresse to acquired memory

\return The function returns a tHostifReturn error code.
\retval kHostifSuccessful       Dynamic buffer acquired ppDynBufBase_p valid.
\retval kHostifInvalidParameter The caller has provided incorrect parameters.
\retval kHostifBridgeDisabled   The bridge is disabled.
\retval kHostifNoResource       No dynamic buffer is available

\ingroup module_hostiflib
*/
//------------------------------------------------------------------------------
#if CONFIG_HOSTIF_PCP == FALSE
tHostifReturn hostif_dynBufAcquire (tHostifInstance pInstance_p, UINT32 pcpBaseAddr_p,
        tHostifInstanceId* pInstId_p, UINT8** ppBufBase_p)
{
    tHostifReturn Ret;
    tHostif *pHostif = (tHostif*)pInstance_p;
    int i;

    if(pInstance_p == NULL || pInstId_p == NULL || ppBufBase_p == NULL)
    {
        Ret = kHostifInvalidParameter;
        goto Exit;
    }

    if(getBridgeEnabled(pHostif) == FALSE)
    {
        Ret = kHostifBridgeDisabled;
        goto Exit;
    }

    Ret = kHostifNoResource;

    for(i=0; i<HOSTIF_DYNBUF_COUNT; i++)
    {
        if(pHostif->apDynBuf[i] == NULL)
        {
            // handle base address in pcp memory space
            pHostif->apDynBuf[i] = (UINT8*)pcpBaseAddr_p;

            hostif_writeDynBufHost(pHostif->pBase, (UINT8)i, pcpBaseAddr_p);

            // Get dynamic buffer address
            *ppBufBase_p = pHostif->aBufMap[i].pBase;

            // Return used dynamic buffer instance
            *pInstId_p = (tHostifInstanceId)i;

            Ret = kHostifSuccessful;
            break;
        }
    }

Exit:
    return Ret;
}
#endif

//------------------------------------------------------------------------------
/**
\brief  This function frees a dynamic buffer acquired by the host

\param  pInstance_p             Host interface instance
\param  instId_p                Dynamic buffer to be freed

\return The function returns a tHostifReturn error code.
\retval kHostifSuccessful       Dynamic buffer freed
\retval kHostifInvalidParameter The caller has provided incorrect parameters.
\retval kHostifNoResource       No dynamic buffer is available to be freed

\ingroup module_hostiflib
*/
//------------------------------------------------------------------------------
#if CONFIG_HOSTIF_PCP == FALSE
tHostifReturn hostif_dynBufFree (tHostifInstance pInstance_p, tHostifInstanceId instId_p)
{
    tHostifReturn Ret = kHostifSuccessful;
    tHostif *pHostif = (tHostif*)pInstance_p;

    if(pInstance_p == NULL || !(instId_p < HOSTIF_DYNBUF_COUNT))
    {
        Ret = kHostifInvalidParameter;
        goto Exit;
    }

    pHostif->apDynBuf[instId_p] = NULL;

    hostif_writeDynBufHost(pHostif->pBase, (UINT8)instId_p, 0);

Exit:
    return Ret;
}
#endif

//------------------------------------------------------------------------------
/**
\brief  This function returns the instance buffer

This function gets the buffer base and size of the addressed instance.

\param  pInstance_p             Host interface instance
\param  instId_p                Addressed instance
\param  ppBufBase_p             Returned buffer base address
\param  pBufSize_p              Returned buffer size

\return The function returns a tHostifReturn error code.
\retval kHostifSuccessful       Dynamic buffer freed
\retval kHostifInvalidParameter The caller has provided incorrect parameters.

\ingroup module_hostiflib
*/
//------------------------------------------------------------------------------
tHostifReturn hostif_getBuf (tHostifInstance pInstance_p, tHostifInstanceId instId_p,
        UINT8** ppBufBase_p, UINT* pBufSize_p)
{
    tHostifReturn ret = kHostifSuccessful;
    tHostif *pHostif = (tHostif*)pInstance_p;

    if(pInstance_p == NULL || ppBufBase_p == NULL || pBufSize_p == NULL ||
            !(instId_p < kHostifInstIdLast))
    {
        ret = kHostifInvalidParameter;
        goto Exit;
    }

    *ppBufBase_p = pHostif->aBufMap[instId_p].pBase;
    *pBufSize_p = pHostif->aBufMap[instId_p].span;

Exit:
    return ret;
}

//------------------------------------------------------------------------------
/**
\brief  This function returns the initialization parameters reference

This function returns the user part of the initialization parameters.

\param  pInstance_p             Host interface instance
\param  ppBufBase_p             Returned buffer base address

\return The function returns a tHostifReturn error code.
\retval kHostifSuccessful       Dynamic buffer freed
\retval kHostifInvalidParameter The caller has provided incorrect parameters.

\ingroup module_hostiflib
*/
//------------------------------------------------------------------------------
tHostifReturn hostif_getInitParam (tHostifInstance pInstance_p, UINT8** ppBase_p)
{
    tHostifReturn   ret = kHostifSuccessful;
    tHostif*        pHostif = (tHostif*)pInstance_p;

    if(pInstance_p == NULL || ppBase_p == NULL)
    {
        ret = kHostifInvalidParameter;
        goto Exit;
    }

#if CONFIG_HOSTIF_PCP != FALSE
    *ppBase_p = pHostif->pInitParam->aUser;
#else
    *ppBase_p = (UINT8*)(((tHostifInitParam*)hostif_readInitBase(pHostif->pBase))->aUser);
#endif

Exit:
    return ret;
}

//============================================================================//
//            P R I V A T E   F U N C T I O N S                               //
//============================================================================//

/* Local functions for Pcp and Host */

//------------------------------------------------------------------------------
/**
\brief  Free pointers which are not NULL

The function frees a pointer if it isn't NULL.

\param  p                       Pointer to be freed
*/
//------------------------------------------------------------------------------
static void freePtr(void *p)
{
    if(p != NULL)
        free(p);
}

//------------------------------------------------------------------------------
/**
\brief  Check magic word of ipcore

This function reads and verifies the magic word from the host interface.

\param  pBase_p     Base address to host interface hardware

\return The function returns a tHostifReturn error code.
*/
//------------------------------------------------------------------------------
static tHostifReturn checkMagic(UINT8* pBase_p)
{
    if(hostif_readMagic(pBase_p) == HOSTIF_MAGIC)
        return kHostifSuccessful;
    else
        return kHostifWrongMagic;
}

//------------------------------------------------------------------------------
/**
\brief  Check version of ipcore

This function reads and verifies the version from the host interface.

\param  pBase_p         Base address to host interface hardware
\param  pSwVersion_p    Pointer to version provided by sw

\return The function returns a tHostifReturn error code.
*/
//------------------------------------------------------------------------------
static tHostifReturn checkVersion(UINT8* pBase_p, tHostifVersion* pSwVersion_p)
{
    tHostifReturn       ret = kHostifSuccessful;
    UINT32              versionField = hostif_readVersion(pBase_p);
    tHostifHwVersion*   pHwVersion = (tHostifHwVersion*)&versionField;

#if CONFIG_HOSTIF_PCP != FALSE
    // Pcp must also check the counting part of the version field.
    if(pHwVersion->cnt != HOSTIF_VERSION_COUNT)
        ret = kHostifWrongVersion;
#endif

    /* Check Revision, Minor and Major */

    if(pHwVersion->version.revision != pSwVersion_p->revision)
        ret = kHostifWrongVersion;

    if(pHwVersion->version.minor != pSwVersion_p->minor)
        ret = kHostifWrongVersion;

    if(pHwVersion->version.major != pSwVersion_p->major)
        ret = kHostifWrongVersion;

    return ret;
}

#if CONFIG_HOSTIF_PCP != FALSE

/* Local functions for Pcp only */

//------------------------------------------------------------------------------
/**
\brief  Turn on/off the host interface bridge

This function turns on or off the bridge logic from Pcp side.
This refuses the host accessing the Pcp-memory space in case of an uninitialized
host interface.
The function writes the specific enable pattern to hardware and reads it back
again.

\param  pHostif_p               Host interface instance
\param  fEnable_p               Enable the bridge with TRUE

\return The function returns a tHostifReturn error code.
*/
//------------------------------------------------------------------------------
static tHostifReturn controlBridge (tHostif *pHostif_p, BOOL fEnable_p)
{
    tHostifReturn Ret = kHostifSuccessful;
    UINT16 dst = 0;
    UINT16 src;

    if(fEnable_p != FALSE)
    {
        dst = HOSTIF_BRIDGE_ENABLE;
    }

    // set value to hw
    hostif_writeBridgeEnable(pHostif_p->pBase, dst);

    // read back value from hw and check if write was successful
    src = hostif_readBridgeEnable(pHostif_p->pBase);

    if((src & HOSTIF_BRIDGE_ENABLE) != dst)
    {
        Ret = kHostifHwWriteError;
        goto Exit;
    }

Exit:
    return Ret;
}

#else

/* Local functions for Host only */

//------------------------------------------------------------------------------
/**
\brief  Host Interrupt Handler

This is the host interrupt handler which should by called by the system if the
irq signal is asserted by the ipcore. This handler acknowledges the processed
interrupt sources and calls the corresponding callbacks registered with
hostif_irqRegHdl().

\param  pArg_p                  The system caller should provide the host
                                interface instance with this parameter.
*/
//------------------------------------------------------------------------------
static void hostifIrqHandler (void *pArg_p)
{
    tHostif *pHostif = (tHostif*)pArg_p;
    UINT16 pendings;
    UINT16 mask;
    int i;

    if(pArg_p == NULL)
    {
        goto Exit;
    }

    pendings = hostif_readIrqPending(pHostif->pBase);

    for(i=0; i<kHostifIrqSrcLast; i++)
    {
        mask = 1 << i;

        //ack irq source first
        if(pendings & mask)
            hostif_ackIrq(pHostif->pBase, mask);

        //then try to execute the callback
        if(pHostif->apfnIrqCb[i] != NULL)
            pHostif->apfnIrqCb[i](pArg_p);
    }

Exit:
    return;
}

//------------------------------------------------------------------------------
/**
\brief  Turn on/off the host interface interrupt master

This function turns on or off the interrupt master from host side.
The function writes the specific enable pattern to hardware and reads it back
again.

\param  pHostif_p               Host interface instance
\param  fEnable_p               Enable interrupt master with TRUE

\return The function returns a tHostifReturn error code.
*/
//------------------------------------------------------------------------------
static tHostifReturn controlIrqMaster (tHostif *pHostif_p, BOOL fEnable_p)
{
    tHostifReturn Ret = kHostifSuccessful;
    UINT16 dst = 0;
    UINT16 src;

    if(fEnable_p != FALSE)
    {
        dst = HOSTIF_IRQ_MASTER_ENABLE;
    }

    // set value to hw
    hostif_writeIrqMasterEnable(pHostif_p->pBase, dst);

    // read back value from hw and check if write was successful
    src = hostif_readIrqMasterEnable(pHostif_p->pBase);

    if((src & HOSTIF_IRQ_MASTER_ENABLE) != dst)
    {
        Ret = kHostifHwWriteError;
        goto Exit;
    }

Exit:
    return Ret;
}

//------------------------------------------------------------------------------
/**
\brief  Get bridge turned on/off

This getter returns whether the bridge is turned on or off.

\param  pHostif_p               Host interface instance

\return The function returns TRUE if the bridge is turned on, otherwise FALSE.
*/
//------------------------------------------------------------------------------
static BOOL getBridgeEnabled (tHostif *pHostif_p)
{
    UINT16 val;

    val = hostif_readBridgeEnable(pHostif_p->pBase);

    if(val & HOSTIF_BRIDGE_ENABLE)
        return TRUE;
    else
        return FALSE;
}

#endif
