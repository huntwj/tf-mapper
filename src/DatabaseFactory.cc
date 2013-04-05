#include <iostream>

#include "DatabaseFactory.h"
#include "MySqlDatabase.h"

namespace tf_mapper
{
    Database *DatabaseFactory::createDatabase(std::string p_type)
    {
        std::cout << "DatabaseFactory createDatabase called." << std::endl;
        MysqlDatabase *md = new MysqlDatabase();
        std::cout << "DatabaseFactory createDatabase done." << std::endl;
        return md;
    }
}
