

#define SO_STRUCT_DECLARATION1(size) typedef struct so_struct_##size { char buff[size]; } HAHSOStruct##size

#define SO_STRUCT_DECLARATION2(prf) \
  SO_STRUCT_DECLARATION1(prf ## 0); \
  SO_STRUCT_DECLARATION1(prf ## 1); \
  SO_STRUCT_DECLARATION1(prf ## 2); \
  SO_STRUCT_DECLARATION1(prf ## 3); \
  SO_STRUCT_DECLARATION1(prf ## 4); \
  SO_STRUCT_DECLARATION1(prf ## 5); \
  SO_STRUCT_DECLARATION1(prf ## 6); \
  SO_STRUCT_DECLARATION1(prf ## 7); \
  SO_STRUCT_DECLARATION1(prf ## 8); \
  SO_STRUCT_DECLARATION1(prf ## 9)

#define SO_STRUCT_DECLARATION3(prf) \
  SO_STRUCT_DECLARATION2(prf ## 0); \
  SO_STRUCT_DECLARATION2(prf ## 1); \
  SO_STRUCT_DECLARATION2(prf ## 2); \
  SO_STRUCT_DECLARATION2(prf ## 3); \
  SO_STRUCT_DECLARATION2(prf ## 4); \
  SO_STRUCT_DECLARATION2(prf ## 5); \
  SO_STRUCT_DECLARATION2(prf ## 6); \
  SO_STRUCT_DECLARATION2(prf ## 7); \
  SO_STRUCT_DECLARATION2(prf ## 8); \
  SO_STRUCT_DECLARATION2(prf ## 9)

SO_STRUCT_DECLARATION1(1);
SO_STRUCT_DECLARATION1(2);
SO_STRUCT_DECLARATION1(3);
SO_STRUCT_DECLARATION1(4);
SO_STRUCT_DECLARATION1(5);
SO_STRUCT_DECLARATION1(6);
SO_STRUCT_DECLARATION1(7);
SO_STRUCT_DECLARATION1(8);
SO_STRUCT_DECLARATION1(9);

SO_STRUCT_DECLARATION2(1);
SO_STRUCT_DECLARATION2(2);
SO_STRUCT_DECLARATION2(3);
SO_STRUCT_DECLARATION2(4);
SO_STRUCT_DECLARATION2(5);
SO_STRUCT_DECLARATION2(6);
SO_STRUCT_DECLARATION2(7);
SO_STRUCT_DECLARATION2(8);
SO_STRUCT_DECLARATION2(9);

SO_STRUCT_DECLARATION3(1);
SO_STRUCT_DECLARATION3(2);
SO_STRUCT_DECLARATION3(3);
SO_STRUCT_DECLARATION3(4);
SO_STRUCT_DECLARATION3(5);
SO_STRUCT_DECLARATION3(6);
SO_STRUCT_DECLARATION3(7);
SO_STRUCT_DECLARATION3(8);
SO_STRUCT_DECLARATION3(9);
SO_STRUCT_DECLARATION3(10);