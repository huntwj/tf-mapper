#ifndef TF_MAPPER_LOGFILEIMPORTER_H_
#define TF_MAPPER_LOGFILEIMPORTER_H_

#include <string>

namespace tf_mapper {

    class LogFileImporter
    {
        public:
            /**
             * Construct a LogFileImporter for a given file.
             */
            LogFileImporter(std::string p_fileName);
    };

}

#endif
