all: tf-mapper

tf-mapper: main.cc App.cc Configuration.cc Database.cc DatabaseFactory.cc LogFileParser.cc Map.cc Mapper.cc MysqlDatabase.cc 
	g++ -I"/opt/local/include" -L"/opt/local/lib" -lglog -g -O0 -o $@ $+
#	g++ -I"/opt/local/include" -L"/opt/local/lib" -lglog -DNDEBUG -g0 -O3 -o $@ $+

clean:
	-rm tf-mapper

