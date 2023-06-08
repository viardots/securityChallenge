#include <stdio.h>
#include <string.h>
#include <unistd.h>
int main(int argc, char ** argv)
{
  char cmd[256]= "/bin/ls ";
  if(argc!=2){
          printf("Vous devez passer un argument! %s dossier\n",argv[0]);
          return -1;
  }
  strcat(cmd, argv[1]);
  execl("/bin/sh","sh","-p","-c",cmd,0);
  return 0;
}
