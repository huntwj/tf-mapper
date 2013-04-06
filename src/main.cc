#include <stdio.h>
#include <stdlib.h>

#include <glog/logging.h>

#include "App.h"

/**
 * Initialize the Google glog system.
 */
void initGlog(char *p_name)
{
    google::InitGoogleLogging(p_name);
    DLOG(INFO) << "stderr";
    DLOG(WARNING) << "stderr";
    FLAGS_logtostderr = 1;
    FLAGS_minloglevel = 1;
}

int main(int argc, char *argv[])
{
    initGlog(argv[0]);

    tf_mapper::App app;
    
    DLOG(WARNING) << "Hello, " << argv[0] << " World!";
    return 0;
}

