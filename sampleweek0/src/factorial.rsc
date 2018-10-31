module demo::basic::Factorial
public int fac3(int N)  { 
  if (N == 0) 
    return 1;
  return N * fac3(N - 1);
}