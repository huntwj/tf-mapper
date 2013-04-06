#include <stdio.h>
#include <stdlib.h>

#include <glog/logging.h>

#include "App.h"

int main(int argc, char *argv[])
{
    google::InitGoogleLogging(argv[0]);
    DLOG(INFO) << "stderr";
    FLAGS_logtostderr = 1;

    tf_mapper::App app;
    
    DLOG(INFO) << "Hello, " << argv[0] << " World!";
    return 0;
}

