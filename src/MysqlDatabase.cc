#include <iostream>

#include <glog/logging.h>

#include "MysqlDatabase.h"

namespace tf_mapper {
    MysqlDatabase::MysqlDatabase() {
        DLOG(INFO) << "MysqlDatabase constructor called.";

        DLOG(INFO) << "MysqlDatabase contructor done.";
    }

    MysqlDatabase::~MysqlDatabase() {
        DLOG(INFO) << "MysqlDatabase destructor called.";

        DLOG(INFO) << "MysqlDatabase destructor done." << std:: endl;
    }
}
