#include <iostream>

#include <glog/logging.h>

#include "Mapper.h"

namespace tf_mapper
{
    Mapper::Mapper(const Configuration &p_config)
    {
        DLOG(INFO) << "Mapper constructor called.";
        this->_map = new Map(p_config);
        DLOG(INFO) << "Mapper constructor done.";
    }

    Mapper::~Mapper()
    {
        DLOG(INFO) << "Mapper destructor called.";
        delete this->_map;
        DLOG(INFO) << "Mapper descructor done.";
    }
}

