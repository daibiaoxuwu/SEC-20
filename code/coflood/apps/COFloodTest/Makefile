COMPONENT=ChaseTestAppC

TINYOS_ROOT_DIR?=/Users/ZhichaoCao/Documents/czc/tinyos-main

PFLAGS += -DCHASE
#PFLAGS += -DLONG_PREAMBLE

## printf client
#PFLAGS += -DENABLE_PR

## mig message
PFLAGS += -DCHASE_TAIL_TEST

PFLAGS += -DCC2420_DEF_RFPOWER=31
PFLAGS += -DTOSH_DATA_LENGTH=128
PFLAGS += -DCC2420_DEF_CHANNEL=22

PFLAGS += -I../../net
PFLAGS += -I../../interface
PFLAGS += -I../../include
PFLAGS += -I../../chips/cc2420/csma
PFLAGS += -I../../chips/cc2420/transmit
PFLAGS += -I../../chips/cc2420/receive
PFLAGS += -I$(TINYOS_ROOT_DIR)/tos/lib/printf

TOSMAKE_PRE_EXE_DEPS = ChaseFloodMsg.java ChaseDelayMsg.java ChaseEnergyMsg.java ChaseTailMsg.java TreeBeaconMsg.java NeighborMsg.java
TOSMAKE_CLEAN_EXTRA = *.class *.java

ChaseFloodMsg.java: ChaseSerial.h
	nescc-mig java $(NESC_PFLAGS) $(CFLAGS) -java-classname=ChaseFloodMsg ChaseSerial.h chase_flood_msg -o $@

ChaseDelayMsg.java: ChaseSerial.h
	nescc-mig java $(NESC_PFLAGS) $(CFLAGS) -java-classname=ChaseDelayMsg ChaseSerial.h chase_delay_msg -o $@

ChaseEnergyMsg.java: ChaseSerial.h
	nescc-mig java $(NESC_PFLAGS) $(CFLAGS) -java-classname=ChaseEnergyMsg ChaseSerial.h chase_energy_msg -o $@

ChaseTailMsg.java: ../../include/Chase.h
	nescc-mig java $(NESC_PFLAGS) $(CFLAGS) -java-classname=ChaseTailMsg ../../include/Chase.h chase_tail_msg -o $@

TreeBeaconMsg.java: COFloodTest.h
	nescc-mig java $(NESC_PFLAGS) $(CFLAGS) -java-classname=TreeBeaconMsg COFloodTest.h tree_beacon_msg -o $@

NeighborMsg.java: COFloodTest.h
	nescc-mig java $(NESC_PFLAGS) $(CFLAGS) -java-classname=NeighborMsg COFloodTest.h neighbor_msg -o $@

## linux
#include $(MAKERULES)

## MacOS
include $(TINYOS_ROOT_DIR)/Makefile.include

