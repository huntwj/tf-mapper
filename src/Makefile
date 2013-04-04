all: tf-mapper

tf-mapper: main.cc MysqlDatabase.cc DatabaseFactory.cc App.cc
	g++ -g -O0 -o $@ $+

clean:
	-rm tf-mapper

