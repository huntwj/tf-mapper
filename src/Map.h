#ifndef TF_MAPPER_MAP_H_
#define TF_MAPPER_MAP_H_

#include "Configuration.h"
#include "Database.h"

namespace tf_mapper
{
    /**
     * The Map class is responsible for representing the world map "as we know
     * it."  While it is database, it is really more of just a cache for the
     * transient Map entity managed by the Mapper.
     */
    class Map
    {
        public:
            /**
             * Construct a Map.
             *
             * @param p_config The configuration object to be used by the map.
             */
            Map(Configuration *p_config);
            ~Map();

        private:
            Database *_database;

            void loadState();
            void saveState();
    };
}

#endif
