#include "DatabaseFactory.h"
#include "MySqlDatabase.h"

namespace tf_mapper
{
    Database *DatabaseFactory::createDatabase(std::string p_type)
    {
        MysqlDatabase *md = new MysqlDatabase();
        return md;
    }
}
