#ifndef TF_MAPPER_MAPPER_H_
#define TF_MAPPER_MAPPER_H_

#include "Map.h"
#include "Configuration.h"

namespace tf_mapper
{
    
    class Mapper
    {
        public:
            Mapper(Configuration *p_config);
            ~Mapper();

        private:
            Map *_map;
    };
}

#endif
