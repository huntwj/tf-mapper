#include <iostream>
#include <string>

#include "Log.h"

namespace tf_mapper
{
    Log::Log(std::string p_class, std::string p_name)
    {
        this->_class = p_class;
        this->_name = p_name;
    }

    Log::Log(std::string p_class)
    {
        this->_class = p_class;
        this->_name = "";
    }

    void Log::enter(std::string p_methodName)
    {
        std::cout << "Entering " << this->_class;
        if (this->_name != "") {
            std::cout << "(" << this->_name << ")";
        }
        std::cout << "::" << p_methodName << std::endl;
    }

    void Log::exit(std::string p_methodName)
    {
        std::cout << "Exiting " << this->_class;
        if (this->_name != "") {
            std::cout << "(" << this->_name << ")";
        }
        std::cout << "::" << p_methodName << std::endl;
    }
}
