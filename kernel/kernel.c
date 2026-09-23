
void main(){
    volatile char *video = (volatile char*)0xB8000;
    int offset = 12 * 80 * 2;

    char *msg = "Hello from C kernel";

    int i = 0;
    while(msg[i] != '\0'){
        video[offset + i * 2] = msg[i];
        video[offset + i * 2 + 1] = 0x0F;
        i++;
    }

}

