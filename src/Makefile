all: tf-mapper

tf-mapper: main.cc App.cc Configuration.cc Database.cc DatabaseFactory.cc Log.cc LogFileParser.cc Map.cc Mapper.cc MysqlDatabase.cc 
	g++ -g -O0 -o $@ $+

clean:
	-rm tf-mapper

