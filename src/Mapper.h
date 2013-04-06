#ifndef TF_MAPPER_MAPPER_H_
#define TF_MAPPER_MAPPER_H_

#include "Map.h"
#include "Configuration.h"

namespace tf_mapper
{
    
    class Mapper
    {
        public:
            /**
             * Construct a Mapper object.
             *
             * @param p_config the configuration to be used by this mapper.
             */
            Mapper(Configuration *p_config);
            ~Mapper();

        private:
            Map *_map;
    };
}

#endif
