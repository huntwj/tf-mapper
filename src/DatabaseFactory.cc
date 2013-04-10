#include <iostream>

#include <glog/logging.h>

#include "DatabaseFactory.h"
#include "MySqlDatabase.h"

namespace tf_mapper
{
    DatabaseFactory::DatabaseFactory(const Configuration &p_config) 
        : _config(p_config)
    {
        DLOG(INFO) << "DatabaseFactory constructor called.";

        DLOG(INFO) << "DatabaseFactory constructor done.";
    }

    Database *DatabaseFactory::createDatabase()
    {
        DLOG(INFO) << "DatabaseFactory createDatabase called.";

        MysqlDatabase *md = new MysqlDatabase();

        DLOG(INFO) << "DatabaseFactory createDatabase done.";
        return md;
    }
}
