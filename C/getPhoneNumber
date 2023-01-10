// Julian James
// E E 474
// Basic C program created through incremental programming.

// Takes user input as a phone number. Characters are turned into a readable phone number.
// EX: 1-800-HOLIDAY becomes 1-800-4654329
int main(void) {
   char phoneChar;   // Current char in phone number string

   printf("Enter phone number: \n");

   scanf("%c", &phoneChar);  // Reads first char of user input
   printf("Numbers only: ");

   while (phoneChar != '\n') {

      if (((phoneChar >= '0') && (phoneChar <= '9')) || (phoneChar == '-')) {
         printf("%c", phoneChar); // Print element as is
      }
      else if ( ((phoneChar >= 'a') && (phoneChar <= 'c')) ||
                ((phoneChar >= 'A') && (phoneChar <= 'C')) ) {
         printf("2");
      }
      else if ( ((phoneChar >= 'd') && (phoneChar <= 'f')) ||
                ((phoneChar >= 'D') && (phoneChar <= 'F')) ) {
         printf("3");
       }
      else if ( ((phoneChar >= 'g') && (phoneChar <= 'i')) ||
                ((phoneChar >= 'G') && (phoneChar <= 'I')) ) {
         printf("4");
       }
      else if ( ((phoneChar >= 'j') && (phoneChar <= 'l')) ||
                ((phoneChar >= 'J') && (phoneChar <= 'L')) ) {
         printf("5");
      }
      else if ( ((phoneChar >= 'm') && (phoneChar <= 'o')) ||
                ((phoneChar >= 'M') && (phoneChar <= 'O')) ) {
         printf("6");
     }
      else if ( ((phoneChar >= 'p') && (phoneChar <= 's')) ||
                ((phoneChar >= 'P') && (phoneChar <= 'S')) ) {
         printf("7");
     }
      else if ( ((phoneChar >= 't') && (phoneChar <= 'v')) ||
                ((phoneChar >= 'T') && (phoneChar <= 'V')) ) {
         printf("8");
     }
      else if ( ((phoneChar >= 'w') && (phoneChar <= 'z')) ||
                ((phoneChar >= 'W') && (phoneChar <= 'Z')) ) {
         printf("9");
     }
      else {
         printf("?");
      }

      scanf("%c", &phoneChar);  // Read next char of user input
   }

   printf("\n");

   return 0;
}
