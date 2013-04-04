#include "App.h"
#include "DatabaseFactory.h"

namespace tf_mapper
{
    App::App()
    {
        this->_database = DatabaseFactory::createDatabase("mysql2");
    }

    App::~App()
    {
        delete this->_database;
    }
}
