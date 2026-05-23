#ifndef F_H_
#define F_H_

// Remove characters with codes from a to b, a < b.
void removerng(char*, char, char);

// Remove every n-th character
void remnth(char*, int);

// Leave last n digits, removing all other characters
void leavelastndig(char*, int);

// Remove repetitions of characters.
char *remrep(char *s);

// Leave only the longest sequence of decimal digits.
char *leavelongestnum(char *s, int n);

// Leave characters with codes from a to b, a < b.
char *leaverng(char *s, char a, char b);

// Remove the last sequence of decimal digits.
char *remlastnum(char *s);

// Scan the first unsigned decimal number.
unsigned int getdec(char *s);

// Scan the first hexadecimal number found in a string.
unsigned int gethex(char *s);

// Reverse the order of digits, leaving the other characters in their original places.
char *reversedig(char *s);

// Reverse the order of letters, leaving the other characters in their places.
char *reverselet(char *s);

// Swap characters in pairs.
char *reversepairs(char *s);

// Replace each sequence of digits with a specified single character.
char *replnum(char *s, char a);

// Capitalize the first character of each word in a string.
char *capwords(char *s);

#endif  // F_H_
