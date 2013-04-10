#ifndef TF_MAPPER_CURSESUI_H_
#define TF_MAPPER_CURSESUI_H_

#include <sys/select.h>

namespace tf_mapper
{
    class CursesRunloop
    {
        public:
            CursesRunloop();
            ~CursesRunloop();
            void run();

        private:
            void resetSelectors();
            void addReadDescriptor(int p_fd);
            fd_set _input;
            int _nfds;
    };
}
#endif
