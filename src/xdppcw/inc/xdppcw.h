//
// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.
//

#pragma once

#define MAXUINT32_STR "4294967295"

typedef struct _PCW_INSTANCE PCW_INSTANCE;

typedef struct _XDP_PCW_RX_QUEUE {
    UINT64 XskFramesDelivered;
    UINT64 XskFramesDropped;
    UINT64 XskFramesTruncated;
    UINT64 XskInvalidDescriptors;
    UINT64 InspectBatches;
    UINT64 InspectFramesPassed;
    UINT64 InspectFramesDropped;
    UINT64 InspectFramesRedirected;
    UINT64 InspectFramesForwarded;
    UINT64 InspectFramesDiscontiguous;
} XDP_PCW_RX_QUEUE;

typedef struct _XDP_PCW_LWF_RX_QUEUE {
    UINT64 MappingFailures;
    UINT64 LinearizationFailures;
    UINT64 ForwardingLowResources;
    UINT64 ForwardingFailuresAllocation;
    UINT64 ForwardingFailuresAllocationLimit;
    UINT64 ForwardingFailuresRscInvalidHeaders;
    UINT64 ForwardingNbsRequested;
    UINT64 ForwardingNbsSent;
    UINT64 LoopbackNblsSkipped;
} XDP_PCW_LWF_RX_QUEUE;

typedef struct _XDP_PCW_TX_QUEUE {
    UINT64 XskInvalidDescriptors;
    UINT64 InjectionBatches;
    UINT64 QueueDepth;
} XDP_PCW_TX_QUEUE;

typedef struct _XDP_PCW_LWF_TX_QUEUE {
    UINT64 FramesDroppedPause;
    UINT64 FramesDroppedNic;
    UINT64 FramesInvalidChecksumOffload;
} XDP_PCW_LWF_TX_QUEUE;

#define STAT_SET(_Stats, _Field, _Value) WriteUInt64NoFence(&((_Stats)->_Field), (_Value))
#define STAT_ADD(_Stats, _Field, _Bias) STAT_SET(_Stats, _Field, ReadUInt64NoFence(&((_Stats)->_Field)) + (_Bias))
#define STAT_INC(_Stats, _Field) STAT_ADD(_Stats, _Field, 1)

#ifdef KERNEL_MODE
//
// Before including the autogenerated PCW helpers, set the PCW version macro to
// the version supported on all versions of Windows. The PCW_VERSION_2 adds
// features we don't use and requires WS2022 or higher.
//
#undef PCW_CURRENT_VERSION
#define PCW_CURRENT_VERSION PCW_VERSION_1

#include <xdppcwcounters.h>
#endif
