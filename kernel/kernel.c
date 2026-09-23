
volatile char *video = (volatile char*)0xB8000;

void print_string(char *str, int offset){
    if(str == 0){    
        return;
    }

    int i = 0;
    while(str[i] != '\0'){
        video[offset + i * 2] = str[i];
        video[offset + i * 2 + 1] = 0x0F;
        i++;
    }
}

void main() {
    int offset = 12 * 80 * 2;
    print_string("Hello from C kernel", offset);
}

