#include <gtest/gtest.h>

TEST(MapTest, CanInstatiateRaw) {
    tf_mapper::Map map; 
}

TEST(MapTest, CanInstantiateWithDB) {
    tf_mapper::DatabaseFactory factory;
    tf_mapper::Database *db = factory.createDatabase();
    tf_mapper::Map map(db);
}

int main(int p_argc, char **p_argv)
{
    ::testing::InitGoogleTest(&argc, p_argv);
    return RUN_ALL_TESTS();
}
