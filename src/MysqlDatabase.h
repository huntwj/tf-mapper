#ifndef TF_MAPPER_MYSQLDATABASE_H_
#define TF_MAPPER_MYSQLDATABASE_H_

#include "Database.h"

namespace tf_mapper {

    class MysqlDatabase : public Database
    {
        public:
            MysqlDatabase();
            virtual ~MysqlDatabase();
    };

}

#endif
