// micro-C example 0


void main(int n) {
  int a[10];
  int dummy;
  int x;
  int y;
  a[6] = 7777;
  print a[6];
  x = y + 42;
  print (dummy = n = 666);
  dummy = n + (n + (n + n)); // OK
  // dummy = n + (n + (n + (n + n))); // Too complex 
  //  n = n + (n + (n + (n + (n + n)))); // Too complex
  print n + (n + (n + (n * 2)));
  print n / 2;
  print n % 2;
}

