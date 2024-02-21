# edl Makefile for ether_ip
#
TOP = ../../..
include $(TOP)/configure/CONFIG
include $(EPICS_BASE)/configure/CONFIG.Dls

DATA += $(patsubst ../%, %, $(wildcard ../*.edl))
DATA += $(patsubst ../%, %, $(wildcard ../*.gif))
DATA += $(patsubst ../%, %, $(wildcard ../*.png))

include $(TOP)/configure/RULES
include $(EPICS_BASE)/configure/RULES.Dls
