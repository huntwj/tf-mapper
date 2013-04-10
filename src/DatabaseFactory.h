#ifndef TF_MAPPER_DATABASEFACTORY_H_
#define TF_MAPPER_DATABASEFACTORY_H_

#include "Configuration.h"
#include "Database.h"

namespace tf_mapper {

    /**
     * Factory class the delegate Database implementation instantiation
     * based on configuration data.
     */
    class DatabaseFactory
    {
        public:
            /**
             * Construct a DatabaseFactory.
             *
             * @param p_config the configuration used to help determine which
             *                 database to instantiate.
             */
            DatabaseFactory(const Configuration &p_config);

            /**
             * Factory method to create a database of a particular type.
             *
             * The caller is responsible for deleting the object created.
             */
            Database *createDatabase();

        private:
            const Configuration &_config;
    };
}

#endif
