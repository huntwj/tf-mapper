#include <iostream>

#include "Map.h"
#include "DatabaseFactory.h"

namespace tf_mapper
{
    Map::Map(Configuration *p_config)
    {
        std::cout << "Map constructor called." << std::endl;
        this->_database = DatabaseFactory::createDatabase("mysql");

        this->loadState();
        std::cout << "Map constructor done." << std::endl;
    }

    Map::~Map()
    {
        std::cout << "Map destructor called." << std::endl;
        this->saveState();

        delete this->_database;
        std::cout << "Map destructor done." << std::endl;
    }

    void Map::loadState()
    {
        std::cout << "Map::loadState called." << std::endl;
        std::cout << "Map::loadState done." << std::endl;
    }

    void Map::saveState()
    {
        std::cout << "Map::saveState called." << std::endl;
        std::cout << "Map::saveState done." << std::endl;
    }
}
