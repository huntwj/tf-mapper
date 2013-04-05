#include <iostream>

#include "MysqlDatabase.h"

namespace tf_mapper {
    MysqlDatabase::MysqlDatabase() {
        std::cout << "MysqlDatabase constructor called." << std::endl;

        std::cout << "MysqlDatabase contructor done." << std::endl;
    }

    MysqlDatabase::~MysqlDatabase() {
        std::cout << "MysqlDatabase destructor called." << std::endl;

        std::cout << "MysqlDatabase destructor done." << std:: endl;
    }
}
