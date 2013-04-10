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
        this->_ui = new CursesRunloop();
        this->_mapper = new Mapper(*(this->_config));

        this->_ui->run();

        DLOG(INFO) << "App constructor done.";
    }

    App::~App()
    {
        DLOG(INFO) << "App destructor called.";
        delete this->_mapper;
        delete this->_ui;
        delete this->_config;
        DLOG(INFO) << "App destructor done.";
    }
}
