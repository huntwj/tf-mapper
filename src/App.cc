#include <iostream>

#include <glog/logging.h>

#include "App.h"
#include "DatabaseFactory.h"

namespace tf_mapper
{
    App::App()
    {
        DLOG(INFO) << "App constructor called.";
        this->_config = new Configuration();
        this->_mapper = new Mapper(this->_config);
        DLOG(INFO) << "App constructor done.";
    }

    App::~App()
    {
        DLOG(INFO) << "App destructor called.";
        delete this->_mapper;
        delete this->_config;
        DLOG(INFO) << "App destructor done.";
    }
}
