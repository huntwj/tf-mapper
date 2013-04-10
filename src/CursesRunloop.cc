#include <curses.h>
#include <glog/logging.h>
#include <panel.h>

#include "CursesRunloop.h"

namespace tf_mapper
{
    CursesRunloop::CursesRunloop()
    {
        initscr();
        if (has_colors()) {
            start_color();
        } else {
            LOG(WARNING) << "Terminal does not support color.";
        }

        cbreak();
        noecho();
        keypad(stdscr, TRUE);
        scrollok(stdscr, TRUE);
        mousemask(ALL_MOUSE_EVENTS | REPORT_MOUSE_POSITION, NULL);
    }

    void CursesRunloop::run()
    {
        for (;;)
        {
            int ch = getch();
            if (ch == 'q') break;

            if (ch == KEY_MOUSE) {
                printw("You hit the mouse:  ");
                MEVENT evt;
                while (getmouse(&evt) == OK) {
                    int y, x;
                    getyx(stdscr, y,x);
                    mvaddch(evt.y, evt.x, '!');
                    move(y,x);
                    printw("id: %d, x: %d, y: %d, z: %d, bstate: %d", evt.id, evt.x, evt.y, evt.z, evt.bstate); 
                }
                printw("\n");
            } else {
                printw("You hit '%s', int value %d.\n", keyname(ch), (int) ch);
            }
        }
    }

    CursesRunloop::~CursesRunloop()
    {
        endwin();
    }
}
