#ifndef TF_MAPPER_DATABASEFACTORY_H_
#define TF_MAPPER_DATABASEFACTORY_H_

#include <string>
#include "Database.h"

namespace tf_mapper {

    class DatabaseFactory
    {
        public:
            static Database *createDatabase(std::string p_type);
    };
}

#endif
