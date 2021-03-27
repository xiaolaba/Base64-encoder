# Base64-encoder
for Wondows XP / win10, MASM source code, resource object &amp; make available. user input the string, i.e. user name &amp; password for email, the program will output the base64 encoded output  

original host, https://sourceforge.net/projects/base64-encoder/

mirror, easy code reading.

base64 encoding scheme, 3 bytes binary data to 4 byte ASCII  


![base64_encoding_theory.JPG](base64_encoding_theory.JPG)  


base64 mapping table, A-Z, a-z, 0-9, +, /

C
/*
** Translation Table as described in RFC1113
*/
static const char cb64[]="ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/";

asm

