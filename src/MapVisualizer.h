#ifndef TF_MAPPER_MAPVISUALIZER_H_
#define TF_MAPPER_MAPVISUALIZER_H_

namespace tf_mapper
{
    /**
     * The MapVisualizer class is responsible for analyzing the map
     * and producing a 2D "picture" of the map or a local region.
     *
     * Note that this class is responsible only for the coordinates
     * not the display.  That is delegated to a user interface class
     * that can interact with an appropriate library, such as curses
     * or file output (PDF, PNG, etc.)
     */
    class MapVisualizer
    {
    }
}

#endif
