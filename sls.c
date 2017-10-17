#include <stdio.h>
#include <string.h>
int main(int argc, char ** argv)
{
  char cmd[256]= "/bin/ls ";
  if(argc!=2){
          printf("Vous devez passer un argument! %s dossier\n",argv[0]);
          return -1;
  }
  strcat(cmd, argv[1]);system(cmd);
  return 0;
}
