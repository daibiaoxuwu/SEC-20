COMPONENT=TopologyTestC

TINYOS_ROOT_DIR?=/Users/ZhichaoCao/Documents/czc/tinyos-main

## printf client
#PFLAGS += -DENABLE_PR

## mig message

PFLAGS += -DCC2420_DEF_RFPOWER=31
PFLAGS += -DTOSH_DATA_LENGTH=128
PFLAGS += -DCC2420_DEF_CHANNEL=22

PFLAGS += -I../../include
PFLAGS += -I$(TINYOS_ROOT_DIR)/tos/lib/printf

TOSMAKE_PRE_EXE_DEPS = TopologyMsg.java
TOSMAKE_CLEAN_EXTRA = *.class *.java

TopologyMsg.java: TopologyTest.h
	nescc-mig java $(NESC_PFLAGS) $(CFLAGS) -java-classname=TopologyMsg TopologyTest.h topology_msg -o $@

## linux
#include $(MAKERULES)

## MacOS
include $(TINYOS_ROOT_DIR)/Makefile.include

