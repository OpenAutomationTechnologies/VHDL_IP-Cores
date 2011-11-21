/**
********************************************************************************
\file		global.h

\brief		Global definitions for POWERLINK CN Development Framework

\author		Josef Baumgartner

\date		20.05.2010

(C) BERNECKER + RAINER, AUSTRIA, A-5142 EGGELSBERG, B&R STRASSE 1

This header file contains global definitions used in the POWERLINK CN
Development Framework.

This file has to be included before other include files.
*******************************************************************************/

#ifndef _CNAPI_GLOBAL_H_
#define _CNAPI_GLOBAL_H_


/******************************************************************************/
/* defines */

/*----------------------------------------------------------------------------*/
/* data types */
#ifndef CHAR
	#define CHAR char
#endif

#ifndef INT8
	#define INT8 char
#endif

#ifndef UCHAR
	#define UCHAR unsigned char
#endif

#ifndef UINT8
	#define UINT8 unsigned char
#endif

#ifndef SHORT
	#define SHORT short int
#endif

#ifndef INT16
	#define INT16 short int
#endif

#ifndef USHORT
	#define USHORT unsigned short int
#endif

#ifndef UINT16
	#define UINT16 unsigned short int
#endif

#ifndef INT
	#define INT int
#endif

#ifndef INT32
	#define INT32 int
#endif

#ifndef UINT
	#define UINT unsigned int
#endif

#ifndef UINT32
	#define UINT32 unsigned int
#endif

#ifndef LONG
	#define LONG long int
#endif

#ifndef ULONG
	#define ULONG unsigned long int
#endif

#ifndef BYTE
	#define BYTE unsigned char
#endif

#ifndef WORD
	#define WORD unsigned short int
#endif

#ifndef DWORD
	#define DWORD unsigned long int
#endif

#ifndef	QWORD
	#define QWORD long long int
#endif

#ifndef BOOL
	#define BOOL unsigned char
#endif

#ifndef NULL
	#define NULL ((void *) 0)
#endif

/*----------------------------------------------------------------------------*/
/* Boolean values */
#ifndef TRUE
	#define TRUE  0xFF
#endif

#ifndef FALSE
	#define FALSE 0x00
#endif

/*----------------------------------------------------------------------------*/
/* error values */
#ifndef	ERROR
	#define	ERROR	-1
#endif

#ifndef OK
	#define	OK		0
#endif


#endif  // #ifndef _CNAPI_GLOBAL_H_



