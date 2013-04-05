#include <iostream>

#include "Database.h"

namespace tf_mapper
{
    Database::~Database()
    {
        std::cout << "Database destructor called." << std::endl;
        std::cout << "Database destructor done." << std::endl;
    }
}
