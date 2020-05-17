COMPONENT=RadioCountToLedsAppC

TINYOS_ROOT_DIR?=/Users/ZhichaoCao/Documents/czc/tinyos-main

PFLAGS += -DENABLE_PR

PFLAGS += -DCC2420_DEF_RFPOWER=2
PFLAGS += -DTOSH_DATA_LENGTH=128
PFLAGS += -DCC2420_DEF_CHANNEL=26

PFLAGS += -I../../include
PFLAGS += -I../../chips/cc2420/csma
PFLAGS += -I../../chips/cc2420/transmit
PFLAGS += -I../../chips/cc2420/receive
PFLAGS += -I$(TINYOS_ROOT_DIR)/tos/lib/printf

TOSMAKE_PRE_EXE_DEPS = RadioCountMsg.py RadioCountMsg.class
TOSMAKE_CLEAN_EXTRA = RadioCountMsg.py RadioCountMsg.class RadioCountMsg.java

RadioCountMsg.py: RadioCountToLeds.h
	nescc-mig python $(CFLAGS) $(NESC_PFLAGS) -python-classname=RadioCountMsg RadioCountToLeds.h radio_count_msg -o $@

RadioCountMsg.class: RadioCountMsg.java
	javac RadioCountMsg.java

RadioCountMsg.java: RadioCountToLeds.h
	nescc-mig java $(CFLAGS) $(NESC_PFLAGS) -java-classname=RadioCountMsg RadioCountToLeds.h radio_count_msg -o $@


include $(TINYOS_ROOT_DIR)/Makefile.include

