#ifndef TF_MAPPER_MAPPER_H_
#define TF_MAPPER_MAPPER_H_

#include "Map.h"
#include "Configuration.h"

namespace tf_mapper
{
    /**
     * The Mapper class is responsible for analyzing inputs from the mud,
     * usually from the LogFile(Importer/Reader) classes but also possibly
     * from the user, and creating a Map instance that satisfies the
     * "observations" made.
     *
     * Note that the map is a transient thing, and in fact sometimes the map
     * is really just a guess when we don't have good data.
     */
    class Mapper
    {
        public:
            /**
             * Construct a Mapper object.
             *
             * @param p_config the configuration to be used by this mapper.
             */
            Mapper(const Configuration &p_config);
            ~Mapper();

        private:
            Map *_map;
    };
}

#endif
