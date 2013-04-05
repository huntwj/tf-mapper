#ifndef TF_MAPPER_LOG_H_
#define TF_MAPPER_LOG_H_

#include <string>

namespace tf_mapper
{
    class Log
    {
        public:
            Log(std::string p_class, std::string p_name);
            Log(std::string p_class);

            void enter(std::string p_methodName);
            void exit(std::string p_methodName);

        private:
            std::string _class;
            std::string _name;

            static unsigned int _indent;
    };

    unsigned int Log::_indent = 0;
}
#endif
