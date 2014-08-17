#include <stdio.h>
#include <stdlib.h>

int pos;

long fsize;
char *string;

void display() {
  int i;
  
  for(i = 0; i < 20 && i < fsize; i++) {
    printf("%4d ", string[i]);
  }
  puts("");
}

void main(void) {
  FILE *f;
  
  int a,b,c;
  
  f = fopen("code.sblq", "rb");
  
  fseek(f, 0, SEEK_END);
  fsize = ftell(f);
  fseek(f, 0, SEEK_SET);
  
  string = malloc(fsize + 1);
  fread(string, fsize, 1, f);
  fclose(f);
  
  pos = 0;
  while(1) {
    display();
    
    a = string[pos++];
    b = string[pos++];
    c = string[pos++];
    
    string[b] -= string[a];
    
    if(string[b] <= 0) {
      pos = c;
    }
  }
}
