/*
 * Name: Julian James
 * Section: AX
 * TA: Nicholas Boren
 * Enables the HuffmanCompressor to compress text files into smaller
 * versions, save them to a file, and decompress Huffman-encoded data back
 * into text files.
 */
import java.util.*;
import java.io.*;
public class HuffmanCode {  
   private Queue<HuffmanNode> q;
   private HuffmanNode overallRoot;
   
   /*
    * Constructs a new HuffmanCode used to encode text.
    * @param int[] frequencies - the frequencies of each letter used to create
    *                            the HuffmanCode used for compression.
    *                            Must be arranged in the order of each
    *                            letter's ASCII code.
    *                           
    */
   public HuffmanCode(int[] frequencies) {
      q = new PriorityQueue<>();
      for (int i = 0; i < frequencies.length; i++) {
         if (frequencies[i] != 0) {
            q.add(new HuffmanNode((char) i, frequencies[i]));
         }
      }
      while (q.size() != 1) {
         HuffmanNode node1 = q.remove();
         HuffmanNode node2 = q.remove();
         q.add(new HuffmanNode(' ', node1.frequency + node2.frequency, node1, node2));
      }
      overallRoot = q.remove();
   }
   
   /*
    * Constructs a HuffmanCode that is used to compress text data.
    * @param Scanner input - Scanner used to read text data and input into 
    *                        the constructor.
    */
   public HuffmanCode(Scanner input) {
      overallRoot = new HuffmanNode(' ');
      while (input.hasNextLine()) {
         int asciiValue = Integer.parseInt(input.nextLine());
         String code = input.nextLine();
         this.overallRoot = HuffmanCodeHelper(overallRoot, (char) asciiValue, code);
      }
   } 
   
   /*
    * Creates a new HuffmanNode binary tree by reading data from the Scanner and constructing
    * new nodes when necessary. Travels down already-existing nodes until it reaches a leaf
    * and then creates a new HuffmanNode that has the given letter.
    * returns - a new HuffmanNode that is the root of the entire HuffmanCode tree.
    */
   private HuffmanNode HuffmanCodeHelper(HuffmanNode root, char letter, String code) {
      if (code.isEmpty() && root.left == null && root.right == null) {
         return new HuffmanNode(letter, -1);
      } else if (code.charAt(0) == '0') {
         if (root.left == null) {
            root.left = new HuffmanNode(' ');
         }
         root.left = HuffmanCodeHelper(root.left, letter, code.substring(1));
      } else if (code.charAt(0) == '1') {
         if (root.right == null) {
            root.right = new HuffmanNode(' ');
         }
         root.right = HuffmanCodeHelper(root.right, letter, code.substring(1));
      }
      return root;
   }
   
   /*
    * Saves the compression data used to encode messages given to the HuffmanCode to a file
    * in standard HuffmanCode format, where the ASCII value of each letter is followed by its
    * HuffmanCode code in binary.
    * @param PrintStream output - used to write the compression data to a file.
    */
   public void save(PrintStream output) {
     save(output, overallRoot, "");
   }
   
   /*
    * Saves the HuffmanCode tree by adding 1's or 0's depending on the location of each letter
    * in the tree. Records the ASCII code of each letter as well as it's HuffmanCode code in
    * binary.
    * @param PrintStream output - used to write each letter and code to a file.
    * @param HuffmanNode root - the root of the HuffmanCode tree that's traversed to get
    *                           a code for each letter.
    * @param String code - the HuffmanCode for the letter that is used to retrieve it from the 
    *                      tree.
    */
   private void save(PrintStream output, HuffmanNode root, String code) {
      if (root.left == null && root.right == null) { //if node is a leaf
         output.println((int) root.letter); //print character and code
         output.println(code);
      } else {
         save(output, root.left, code + "0"); // go down left, add 0 to code
         save(output, root.right, code + "1"); //go down right, add 1 to code.
      }
      
   }
   
   /*
    * Reads the compressed data and prints it (to a file, console, etc.) into plain text.
    * Requires given data to be in standard HuffmanCode format.
    * @param BitInputStream input - provides the data that is decompressed and printed out.
    * @param PrintStream output - used to write the data to a file/console.
    */
   public void translate(BitInputStream input, PrintStream output) {
      while(input.hasNextBit()) {
         translateHelper(input, output, overallRoot);
      }
   }
   
   /*
    * Travels down the HuffmanCode tree bit by bit until hitting the letter that is assinged
    * to the given code. Then, it prints it in plain text to the output.
    * @param BitInputStream input - used to get the bit codes for each letter of text.
    * @param PrintStream output - used to write the plain text.
    * @param HuffmanNode root - used to traverse up/down the tree.
    */
   private void translateHelper(BitInputStream input, PrintStream output, HuffmanNode root) {
      if (root.left == null && root.right == null) {
         output.write(root.letter);
      } else {
         int bit = input.nextBit();
         if (bit == 0) {
            translateHelper(input, output, root.left);
         } else {
            translateHelper(input, output, root.right);
         }
      }
   }
   
   /*
    * A sinle node in the HuffmanCode that stores the letter, the frequency of the letter,
    * and a left/right HuffmanNode.
    */
   private static class HuffmanNode implements Comparable<HuffmanNode> {
      public char letter;
      public int frequency;
      public HuffmanNode left;
      public HuffmanNode right;
      
      /*
       * Constructs a HuffmanNode with the given letter but not linked to
       * any nodes. Frequency is -1 when not given.
       * @param char letter - the ASCII letter to be stored in the HuffmanNode.
       */
      public HuffmanNode(char letter) {
         this(letter, -1, null, null);
      }
      
      /*
       * Constructs a HuffmanNode with the given letter and frequency.
       * @param char letter - the ASCII letter to be stored in the HuffmanNode.
       * @param int frequency - the given frequency of the letter given.
       */
      public HuffmanNode(char letter, int frequency) {
         this(letter, frequency, null, null);
      }
      
      /*
       * Constructs a HuffmanNode with the given letter and frequency that is also linked to
       * the two given HuffmanNodes.
       * @param char letter - the letter to be stored in the HuffmanNode.
       * @param int frequency - the frequency of the letter stored in the HuffmanNode.
       * @param HuffmanNode left - the left, or "0" Node attached to this HuffmanNode.
       * @param HuffmanNode right - the right, or "1" HuffmanNode attached to this HuffmanNode.
       */
      public HuffmanNode(char letter, int frequency, HuffmanNode left, HuffmanNode right) {
         this.letter = letter;
         this.frequency = frequency;
         this.left = left;
         this.right = right;
      }
      
      /* Compares two HuffmanNodes by frequency.
       * @param HuffmanNode other - the other HuffmanNode which this one is compared to.
       * @returns - 1 if this HuffmanNode has a higher frequency
       *            0 if both HuffmanNodes have the same frequency.
       *            -1 if the other HuffmanNode has a higher frequency.
       */
      public int compareTo(HuffmanNode other) {
         return this.frequency - other.frequency;
      }
   }
}
