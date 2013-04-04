#ifndef TF_MAPPER_APP_H_
#define TF_MAPPER_APP_H_

#include "Database.h"

namespace tf_mapper
{
    class App
    {
        public:
            App();
            ~App();

        private:
            Database *_database;
    };
}
#endif
