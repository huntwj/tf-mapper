#include <stdio.h>
#include <stdlib.h>

#include <glog/logging.h>

#include "App.h"

int main(int argc, char *argv[])
{
    google::InitGoogleLogging(argv[0]);
    DLOG(INFO) << "stderr";
    DLOG(WARNING) << "stderr";
    FLAGS_logtostderr = 1;
    FLAGS_minloglevel = 1;

    tf_mapper::App app;
    
    DLOG(WARNING) << "Hello, " << argv[0] << " World!";
    return 0;
}

