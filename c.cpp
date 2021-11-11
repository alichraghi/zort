#include<bits/stdc++.h>
using namespace std;

void print(long *vec, long n) {
   for(long i = 1; i<=n; i++)
      cout << vec[i] << " ";
   cout << "\n";
}

long getMax(long vec[], long n) {
   long max = vec[1];
   for(long i = 2; i<=n; i++) {
      if(vec[i] > max)
         max = vec[i];
   }
   return max;
}
void countSort(long *vec, long n) {
   long output[n+1];
   long max = getMax(vec, n);
   long count[max+1];
   for(long i = 0; i<=max; i++)
      count[i] = 0;
   for(long i = 1; i <=n; i++)
      count[vec[i]]++;
   for(long i = 1; i<=max; i++)
      count[i] += count[i-1];
   for(long i = n; i>=1; i--) {
      output[count[vec[i]]] = vec[i];
      count[vec[i]] -= 1;
   }
   for(long i = 1; i<=n; i++) {
      vec[i] = output[i];
   }
}
int main() {
   long n;
   cout << "Enter the size of array: ";
   cin >> n;
   long arr[n+1];
   cout << "Enter elements:" << endl;
   for(long i = 1; i<=n; i++)
      cin >> arr[i];
   cout << "Unsorted array: ";
   print(arr, n);
   countSort(arr, n);
   cout << "Sorted array: ";
   print(arr, n);
}