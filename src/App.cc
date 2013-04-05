#include <iostream>

#include "App.h"
#include "DatabaseFactory.h"

namespace tf_mapper
{
    App::App()
    {
        std::cout << "App constructor called." << std::endl;
        this->_config = new Configuration();
        this->_mapper = new Mapper(this->_config);
        std::cout << "App constructor done." << std::endl;
    }

    App::~App()
    {
        std::cout << "App destructor called." << std::endl;
        delete this->_mapper;
        delete this->_config;
        std::cout << "App destructor done." << std::endl;
    }
}
