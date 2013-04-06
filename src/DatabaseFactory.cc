#include <iostream>

#include <glog/logging.h>

#include "DatabaseFactory.h"
#include "MySqlDatabase.h"

namespace tf_mapper
{
    Database *DatabaseFactory::createDatabase(std::string p_type)
    {
        DLOG(INFO) << "DatabaseFactory createDatabase called.";
        MysqlDatabase *md = new MysqlDatabase();
        DLOG(INFO) << "DatabaseFactory createDatabase done.";
        return md;
    }
}
