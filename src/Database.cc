#include <iostream>

#include <glog/logging.h>

#include "Database.h"

namespace tf_mapper
{
    Database::~Database()
    {
        DLOG(INFO) << "Database destructor called.";
        DLOG(INFO) << "Database destructor done.";
    }
}
