#include <iostream>

#include <glog/logging.h>

#include "Map.h"
#include "DatabaseFactory.h"

namespace tf_mapper
{
    Map::Map(Configuration *p_config)
    {
        DLOG(INFO) << "Map constructor called.";
        DatabaseFactory factory(*p_config);
        this->_database = factory.createDatabase();

        this->loadState();
        DLOG(INFO) << "Map constructor done.";
    }

    Map::~Map()
    {
        DLOG(INFO) << "Map destructor called.";
        this->saveState();

        delete this->_database;
        DLOG(INFO) << "Map destructor done.";
    }

    void Map::loadState()
    {
        DLOG(INFO) << "Map::loadState called.";
        DLOG(INFO) << "Map::loadState done.";
    }

    void Map::saveState()
    {
        DLOG(INFO) << "Map::saveState called.";
        DLOG(INFO) << "Map::saveState done.";
    }
}
