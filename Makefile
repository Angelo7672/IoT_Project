COMPONENT=WeatherSensorsNetworkAppC
CFLAGS += -I$(TOSDIR)/lib/printf
CFLAGS += -DNEW_PRINTF_SEMANTICS
include $(MAKERULES)

