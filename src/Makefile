all: tf-mapper

DEBUG_FLAGS = -g -O0
#DEBUG_FLAGS = -DNDEBUG -g0 -O3

INCLUDE_PATH = /opt/local/include

GPPC = g++ -c -I"$(INCLUDE_PATH)" $(DEBUG_FLAGS)

objects = main.o App.o Configuration.o Database.o DatabaseFactory.o LogFileParser.o Map.o Mapper.o MysqlDatabase.o

tf-mapper: $(objects)
	g++ -L"/opt/local/lib" -lglog -O3 -o $@ $+

main.o: main.cc App.h
	$(GPPC) main.cc

App.o: App.cc App.h Configuration.h DatabaseFactory.h Mapper.h
	$(GPPC) App.cc

Configuration.o: Configuration.cc Configuration.h
	$(GPPC) Configuration.cc

Database.o: Database.cc Database.h
	$(GPPC) Database.cc

DatabaseFactory.o: DatabaseFactory.cc DatabaseFactory.h Database.h MysqlDatabase.h
	$(GPPC) DatabaseFactory.cc

LogFileImporter.o: LogFileImporter.cc LogFileImporter.h
	$(GPPC) LogFileImporter.cc

LogFileParser.o: LogFileParser.cc LogFileParser.h
	$(GPPC) LogFileParser.cc

Map.o: Map.cc Map.h Configuration.h Database.h
	$(GPPC) Map.cc

Mapper.o: Mapper.cc Mapper.h Configuration.h Map.h
	$(GPPC) Mapper.cc

MysqlDatabase.o: MysqlDatabase.cc Mapper.h Database.h
	$(GPPC) MysqlDatabase.cc

clean:
	-rm tf-mapper $(objects)

