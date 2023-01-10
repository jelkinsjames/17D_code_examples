/**
* Name: Julian James
* Section: AX
* TA: Nicholas Boren
* This plays a 20-Questions style game with the user, guessing different objects until
* running out of answers. It then asks the user what the object was, a question that would
* help the computer determine the object next time it plays, and adds it to the possible
* questions and answers it can produce.
*/
import java.util.*;
import java.io.*;
public class QuestionsGame {
   private Scanner console;
   private QuestionNode firstQuestion;
   
   /**
   * Constructs a QuestionsGame with an initial answer of "computer" and no questions.
   */
   public QuestionsGame() {
      console = new Scanner(System.in);
      firstQuestion = new QuestionNode("computer");
   }
   
   /**
   * Reads a file to then construct a question/answer tree for the QuestionGame.
   * @param input - the object used to read the file.
   */
   public void read(Scanner input) {
      firstQuestion = readHelper(input);
   }
   
   /**
   * Takes in two lines of the input, checks to see if is a question, and then goes
   * down the question tree.
   * @param input - the Scanner that reads the file for the input
   * @returns - A QuestionNode with nodes of all the question/answer pairs in the given file.
   */
   private QuestionNode readHelper(Scanner input) {
      String type = input.nextLine();
      String data = input.nextLine();
      QuestionNode root = new QuestionNode(data);
      if (type.contains("Q:")) { //if it's a question, go down both trees
         root.yes = readHelper(input);
         root.no = readHelper(input);
      } //if its an answer, stop here
      return root;
   }
   
   /**
   * Prints the question/answer tree to a file in a standard format.
   * @param output - passed to print the data in the tree to the file.
   */
   public void write(PrintStream output) {
      write(output, firstQuestion);
   }
   
   /**
   * Writes the data in the tree to a text file by checking to see if the given
   * String in the root has a "?" at the end, determining whether or not it is a
   * Q or A, prints the data, then goes down both the no and yes trees.
   * @param output - the object that prints the data to the file.
   * @param root - the given root of the tree whose data is explored.
   */
   private void write(PrintStream output, QuestionNode root) {
      if (root != null) {
         if (root.data.charAt((root.data.length() - 1)) == '?') { //Q if question and A if answer.
            output.println("Q:");
         } else {
            output.println("A:");
         }
         output.println(root.data);
         write(output, root.yes); //go down yes
         write(output, root.no); //go down no
      }
   }
   
   /**
   * Plays the entire guessing game with the user, asking yes or no questions
   * until it runs out of options. If its' final guess is wrong, it will ask the user
   * to give it the object the user thought of and a yes/no question that would
   * allow the computer to guess it.
   */
   public void askQuestions() {
      firstQuestion = askQuestions(firstQuestion);
   }
   
   /**
   * This uses a recursive method to ask the user the yes/no questions all the way
   * down the tree. If the final answer is wrong, it appends and returns new nodes
   * to the end of the tree.
   * @param root - the given root of the question/answer tree.
   * @returns - a QuestionNode that branches off into the entire question/answer tree used
   *            for the game.
   */
   private QuestionNode askQuestions(QuestionNode root) {
      if (root.yes == null && root.no == null) { //if node is a leaf
         if (yesTo("Would your object happen to be " + root.data + "?")) {//ask if node is the answer
            System.out.println("Great, I got it right!"); // if yes, computer wins
            return root;
         } else { //else (no)
            System.out.print("What is the name of your object? ");
            String name = console.nextLine();
            System.out.println("Please give me a yes/no question that");
            System.out.println("distinguishes between your object");
            System.out.print("and mine--> ");
            String question = console.nextLine(); //record the new question and add it to tree
            if (yesTo("And what is the answer for your object?")) {
               root = new QuestionNode(question, new QuestionNode(name), root);
            } else {
               root = new QuestionNode(question, root, new QuestionNode(name));
            }
         }
      } else { //node given is not a leaf
         if (yesTo(root.data)) {
            root.yes = askQuestions(root.yes);
         } else {
            root.no = askQuestions(root.no);
         }
      }
      return root;
   }
   
   // Do not modify this method in any way
   // post: asks the user a question, forcing an answer of "y" or "n";
   //       returns true if the answer was yes, returns false otherwise
   private boolean yesTo(String prompt) {
      System.out.print(prompt + " (y/n)? ");
      String response = console.nextLine().trim().toLowerCase();
      while (!response.equals("y") && !response.equals("n")) {
         System.out.println("Please answer y or n.");
         System.out.print(prompt + " (y/n)? ");
         response = console.nextLine().trim().toLowerCase();
      }
      return response.equals("y");
   }
   
   /**
   * These are the QuestionNodes that are used to store question/answer data for the
   * game.
   */
   private static class QuestionNode {
      public final String data;
      public QuestionNode yes;
      public QuestionNode no;
      
      /**
      * Constructs a QuestionNode with the given String but empty yes/no nodes.
      * @param data - the given string
      */
      public QuestionNode(String data) {
         this(data, null, null);
      }
      
      /**
      * Constructs a QuestionNode with given data String and QuestionNode yes and no's.
      * @param data - the given data String in the node.
      * @param yes - the given QuestionNode to come to if the user answers yes.
      * @param no - the given QuestionNode to come to if the user answers no.
      */
      public QuestionNode(String data, QuestionNode yes, QuestionNode no) {
         this.data = data;
         this.yes = yes;
         this.no = no;
      }
   }
}
