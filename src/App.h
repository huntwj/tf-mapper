#ifndef TF_MAPPER_APP_H_
#define TF_MAPPER_APP_H_

#include "Configuration.h"
#include "Mapper.h"

namespace tf_mapper
{
    class App
    {
        public:
            App();
            ~App();

        private:
            Mapper *_mapper;
            Configuration *_config;
    };
}
#endif
