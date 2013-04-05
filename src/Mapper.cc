#include <iostream>

#include "Mapper.h"

namespace tf_mapper
{
    Mapper::Mapper(Configuration *p_config)
    {
        std::cout << "Mapper constructor called." << std::endl;
        this->_map = new Map(p_config);
        std::cout << "Mapper constructor done." << std::endl;
    }

    Mapper::~Mapper()
    {
        std::cout << "Mapper destructor called." << std::endl;
        delete this->_map;
        std::cout << "Mapper descructor done." << std::endl;
    }
}

