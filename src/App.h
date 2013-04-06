#ifndef TF_MAPPER_APP_H_
#define TF_MAPPER_APP_H_

#include "Configuration.h"
#include "Mapper.h"

namespace tf_mapper
{
    /**
     * Main application class and OO entry point.
     */
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
