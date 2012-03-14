#include "system.h"

#include "stdio.h"
#include "stdlib.h"
#include <sys/alt_cache.h>
#include "mtdlib.h"
#include "global.h"

#define MASTER_TEST_SMALL

#ifdef MASTER_TEST_SMALL
#define MASTER_TEST_WAIT            10000000
#endif

#ifdef __MASTERTESTDEVICE
#else
#define MASTER_TEST_DEVICE_BASE     0
#warning "Master Test Device not found!"
#endif

#ifndef SDRAM_0_BASE
#define SDRAM_0_BASE                0x00000000
//#define SDRAM_0_SPAN                134217728
#define SDRAM_0_SPAN                67108864
#endif

#ifndef SRAM_0_BASE
#define SRAM_0_BASE                 0x08000000
#define SRAM_0_SPAN                 1048576
#endif

//set memory to be tested for standard test
#define RAM_BASE                    SDRAM_0_BASE
#define RAM_SPAN                    SDRAM_0_SPAN
//#define RAM_BASE                    SRAM_0_BASE
//#define RAM_SPAN                    SRAM_0_SPAN

#define PRINT0(x)                   printf(x)
#define PRINT1(x, a)                printf(x, a)
#define PRINT2(x, a, b)             printf(x, a, b)
#define PRINT3(x, a, b, c)          printf(x, a, b, c)

#define SCAN(x, a)                  scanf(x, a)

#define CLK_TICK_NS                 10

DWORD audwMasterTestInstanceBase[] = \
{
    MASTERTESTDEVICE_0_BASE,
    MASTERTESTDEVICE_1_BASE,
    MASTERTESTDEVICE_2_BASE,
    MASTERTESTDEVICE_3_BASE,
    /* add more master test devices here */
    -1 /* the last value must be -1! */
};

DWORD audwMasterTestDefault[][5] = \
{
    /* base0, base1, burst, type, timeout */
    {RAM_BASE + (0*RAM_SPAN)/8, RAM_BASE + (1*RAM_SPAN)/8, 64/4, 0xE, 0},
    {RAM_BASE + (2*RAM_SPAN)/8, RAM_BASE + (3*RAM_SPAN)/8, 64/4, 0xE, 0},
    {RAM_BASE + (4*RAM_SPAN)/8, RAM_BASE + (5*RAM_SPAN)/8, 32/4, 0xE, 0},
    {RAM_BASE + (6*RAM_SPAN)/8, RAM_BASE + (7*RAM_SPAN)/8, 32/4, 0xE, 0}
};

int main(void)
{
    tMtdLibReturn ret;
    tMtdLibInitParam initParam;
    tMtdLibStatistic statistic;
    int iSelectDevice;
    int iSelectDeviceMax;

    alt_icache_flush_all();
    alt_dcache_flush_all();

    PRINT0("Search for Master Test Devices...");

    for(iSelectDevice = 0; iSelectDevice < MTDLIB_MAX_INSTANCES; iSelectDevice++)
    {
        if(audwMasterTestInstanceBase[iSelectDevice] == -1)
        {
            break;
        }
    }

    //set number of devices
    iSelectDeviceMax = iSelectDevice;

    PRINT1(" %i found!\n", iSelectDeviceMax);

    //initialize devices
    initParam.m_iInstanceNumber = iSelectDeviceMax;

    for(iSelectDevice = 0; iSelectDevice < iSelectDeviceMax; iSelectDevice++)
    {
        initParam.m_audwBase[iSelectDevice] = audwMasterTestInstanceBase[iSelectDevice];
    }

    PRINT0("Master Test Device:\n");
    PRINT0("\tInitialization ... ");

    ret = mtdLibInit(initParam);

    if(ret == mtdLibSuccessful)
    {
        PRINT0("pass\n");
    }
    else
    {
        PRINT0("fail\n");
        goto exit;
    }

#ifdef MASTER_TEST_SMALL

    int i;

    //initialize all master devices
    for(i=0; i<iSelectDeviceMax; i++)
    {
        ret = mtdLibSuccessful;
        ret |= mtdLibSetTransferBaseAddress(i, audwMasterTestDefault[i][0], 1); //base0
        ret |= mtdLibSetTransferBaseAddress(i, audwMasterTestDefault[i][1], 2); //base1
        ret |= mtdLibSetTransferBurstSize(i, audwMasterTestDefault[i][2]); //burst
        ret |= mtdLibSetTransferType(i, audwMasterTestDefault[i][3]); //type
        ret |= mtdLibSetTimeout(i, audwMasterTestDefault[i][4]); //timeout

        if(ret != mtdLibSuccessful)
        {
            PRINT0("fail!\n");
            goto exit;
        }
    }

    //fire them all
    for(i=0; i<iSelectDeviceMax; i++)
    {
        ret = mtdLibFire(i); //fire

        if(ret != mtdLibSuccessful)
        {
            PRINT0("fail!\n");
            goto exit;
        }
    }

    for(i=0; i<MASTER_TEST_WAIT; i++)
    {
        asm("NOP");
    }

    //stop them all
    for(i=0; i<iSelectDeviceMax; i++)
    {
        ret = mtdLibStop(i); //stop

        if(ret != mtdLibSuccessful)
        {
            PRINT0("fail!\n");
            goto exit;
        }
    }

    //get statistics
    for(i=0; i<iSelectDeviceMax; i++)
    {
        ret = mtdLibGetStatistic(i, &statistic);

        if(ret != mtdLibSuccessful)
        {
            PRINT0("fail!\n");
            goto exit;
        }

        PRINT1("Device Number = %i\n", (int)i);
        PRINT2("1st Latency:\n\tMin = %d ns | Max = %d ns\n", (int)(statistic.m_udwMin1stLatency * CLK_TICK_NS), \
                (int)(statistic.m_udwMax1stLatency * CLK_TICK_NS));
        PRINT2("Transfer Length:\n\tMin = %d ns | Max = %d ns\n", (int)(statistic.m_udwMinTransLength * CLK_TICK_NS), \
                (int)(statistic.m_udwMaxTransLength * CLK_TICK_NS));
        PRINT0("\n");
    }

#else

    int iChoice;
    DWORD udwVal;

    while(1)
    {
        PRINT0("\n*** TEST USER INTERFACE ***\n");
        PRINT1("0 .. %i : Select Device\n", iSelectDeviceMax-1);
        PRINT1("%i : Set default config\n", MTDLIB_MAX_INSTANCES);
        PRINT1("%i : Get Statistics\n", MTDLIB_MAX_INSTANCES+1);
        PRINT1("%i : Fire all\n", MTDLIB_MAX_INSTANCES+2);
        PRINT1("%i : Stop all\n", MTDLIB_MAX_INSTANCES+3);
        PRINT0("choice=");
        SCAN("%i", &iSelectDevice);

        //if(iSelectDevice >= iSelectDeviceMax)
        if((0 <= iSelectDevice) && (iSelectDevice < MTDLIB_MAX_INSTANCES))
        {

        }
        else
        {
            switch(iSelectDevice)
            {
                case MTDLIB_MAX_INSTANCES : //set default config
                    {
                        int i;

                        for(i=0; i<iSelectDeviceMax; i++)
                        {
                            ret = mtdLibSuccessful;
                            ret |= mtdLibSetTransferBaseAddress(i, audwMasterTestDefault[i][0], 1); //base0
                            ret |= mtdLibSetTransferBaseAddress(i, audwMasterTestDefault[i][1], 2); //base1
                            ret |= mtdLibSetTransferBurstSize(i, audwMasterTestDefault[i][2]); //burst
                            ret |= mtdLibSetTransferType(i, audwMasterTestDefault[i][3]); //type
                            ret |= mtdLibSetTimeout(i, audwMasterTestDefault[i][4]); //timeout

                            if(ret != mtdLibSuccessful)
                            {
                                PRINT0("fail!\n");
                                goto exit;
                            }
                        }
                    }
                    break;
                case MTDLIB_MAX_INSTANCES+1 : //get statistics
                    {
                        int i;

                        for(i=0; i<iSelectDeviceMax; i++)
                        {
                            ret = mtdLibGetStatistic(i, &statistic);

                            if(ret != mtdLibSuccessful)
                            {
                                PRINT0("fail!\n");
                                goto exit;
                            }

                            PRINT1("Device Number = %i\n", (int)i);
                            PRINT2("1st Latency:\n\tMin = %d ns | Max = %d ns\n", (int)(statistic.m_udwMin1stLatency * CLK_TICK_NS), \
                                    (int)(statistic.m_udwMax1stLatency * CLK_TICK_NS));
                            PRINT2("Transfer Length:\n\tMin = %d ns | Max = %d ns\n", (int)(statistic.m_udwMinTransLength * CLK_TICK_NS), \
                                    (int)(statistic.m_udwMaxTransLength * CLK_TICK_NS));
                            PRINT0("\n");
                        }
                    }
                    break;
                case MTDLIB_MAX_INSTANCES+2 : //fire all
                    {
                        int i;

                        for(i=0; i<iSelectDeviceMax; i++)
                        {
                            ret = mtdLibFire(i); //fire

                            if(ret != mtdLibSuccessful)
                            {
                                PRINT0("fail!\n");
                                goto exit;
                            }
                        }
                    }
                    break;
                case MTDLIB_MAX_INSTANCES+3 : //stop all
                    {
                        int i;

                        for(i=0; i<iSelectDeviceMax; i++)
                        {
                            ret = mtdLibStop(i); //stop

                            if(ret != mtdLibSuccessful)
                            {
                                PRINT0("fail!\n");
                                goto exit;
                            }
                        }
                    }
                    break;
                default :
                    break;
            }
            continue;
        }

        PRINT0("\n*** TEST CASE MENU ***\n");
        PRINT0("1 : Set Transfer Base Address\n");
        PRINT0("2 : Set Transfer Burst Size\n");
        PRINT0("3 : Set Transfer Type\n");
        PRINT0("4 : Set Transfer Timeout\n");
        PRINT0("5 : Fire!\n");
        PRINT0("6 : Stop!\n");
        PRINT0("9 : Reset Statistic\n");
        PRINT0("Select function = ");
        SCAN("%i", &iChoice);

        //PRINT2("Device = %i\nChoice = %i\n", iSelectDevice, iChoice);

        switch(iChoice)
        {
            case 1 : //transfer base
                PRINT0("Transfer Base 1 = 0x");
                SCAN("%X", (unsigned int*)&udwVal);
                ret = mtdLibSetTransferBaseAddress(iSelectDevice, udwVal, 1);

                if(ret != mtdLibSuccessful)
                {
                    PRINT0("fail!\n");
                    goto exit;
                }

                PRINT0("Transfer Base 2 = 0x");
                SCAN("%X", (unsigned int*)&udwVal);
                ret = mtdLibSetTransferBaseAddress(iSelectDevice, udwVal, 2);
                break;
            case 2 : //transfer burst size
                PRINT0("Transfer Burst Size = ");
                SCAN("%i", (unsigned int*)&udwVal);
                ret = mtdLibSetTransferBurstSize(iSelectDevice, udwVal);

                if(ret != mtdLibSuccessful)
                {
                    PRINT0("fail!\n");
                    goto exit;
                }
                break;
            case 3 : //transfer type
                PRINT0("Transfer Type\n");
                PRINT1("write = 0x%X\n", MTDLIB_CONTROL_WRITE);
                PRINT1("read = 0x%X\n", MTDLIB_CONTROL_READ);
                PRINT1("burst = 0x%X\n", MTDLIB_CONTROL_BURST);
                PRINT1("continuous = 0x%X\n", MTDLIB_CONTROL_CONTI);
                PRINT0("0x");
                SCAN("%X", (unsigned int*)&udwVal);
                ret = mtdLibSetTransferType(iSelectDevice, udwVal);

                if(ret != mtdLibSuccessful)
                {
                    PRINT0("fail!\n");
                    goto exit;
                }
                break;
            case 4 : //transfer timeout
                PRINT0("Transfer Timeout = ");
                SCAN("%i", (unsigned int*)&udwVal);
                ret = mtdLibSetTimeout(iSelectDevice, udwVal);

                if(ret != mtdLibSuccessful)
                {
                    PRINT0("fail!\n");
                    goto exit;
                }
                break;
            case 5 : //fire!
                ret = mtdLibFire(iSelectDevice);

                if(ret != mtdLibSuccessful)
                {
                    PRINT0("fail!\n");
                    goto exit;
                }
                break;
            case 6 : //stop!
                ret = mtdLibStop(iSelectDevice);

                if(ret != mtdLibSuccessful)
                {
                    PRINT0("fail!\n");
                    goto exit;
                }
                break;
            case 9 : //reset statistic
                ret = mtdLibResetStatistic(iSelectDevice);

                if(ret != mtdLibSuccessful)
                {
                    PRINT0("fail!\n");
                    goto exit;
                }
                break;
            default :
                PRINT0("wrong choice!\n");
                break;
        }

        PRINT0("\n");
    }

    while(1);

#endif

exit:
    if(ret != mtdLibSuccessful)
    {
        PRINT1("\nExit due to error (ret = %d)\n", ret);
    }

    while(1);

    return 0;
}
