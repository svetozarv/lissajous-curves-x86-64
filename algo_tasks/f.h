#ifndef F_H_
#define F_H_

// [DONE] Remove characters with codes from a to b, a < b.
void removerng(char *s, char a, char b);

// [DONE] Remove every n-th character
void remnth(char *s, int n);

// [DONE]Leave last n digits, removing all other characters
void leavelastndig(char *s, int n);

// [DONE] Remove repetitions of characters.
void remrep(char *s);

// [DONE] Leave characters with codes from a to b, a < b.
void leaverng(char *s, char a, char b);

// [DONE] Swap characters in pairs.
void reversepairs(char *s);


// Leave only the longest sequence of decimal digits.
void leavelongestnum(char *s, int n);

// Remove the last sequence of decimal digits.
void remlastnum(char *s);

// Scan the first unsigned decimal number.
unsigned int getdec(char *s);

// Scan the first hexadecimal number found in a string.
unsigned int gethex(char *s);

// Reverse the order of digits, leaving the other characters in their original places.
void reversedig(char *s);

// Reverse the order of letters, leaving the other characters in their places.
void reverselet(char *s);

// Replace each sequence of digits with a specified single character.
void replnum(char *s, char a);

// Capitalize the first character of each word in a string.
void capwords(char *s);

#endif  // F_H_
