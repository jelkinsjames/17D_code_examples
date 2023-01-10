/*
 * Authors: Benjamin, Julian
 * Last Edited: 10/26/2022
 * Description: This script moves someone with a DEAD task and no protections to the Sandbox.
 * (Assumption):
 */

// Official ID: 1k19sS9NfwlVfG7GCCf18LO69pr4reSOTN6v1lY2nykQ
const SEAL_LIFE_ID = '1k19sS9NfwlVfG7GCCf18LO69pr4reSOTN6v1lY2nykQ';

// Official ID: 1Lmf5mhf-Z77hNyBDum1cgODdHq3i3AHOg6cbrMI2KWQ
const SANDBOX_ID = '1Lmf5mhf-Z77hNyBDum1cgODdHq3i3AHOg6cbrMI2KWQ';
const START_ROW = 9;
const SANDBOX_START_ROW = 7;
const ADMIN_EMAIL = "sealpro247@gmail.com";
const ADMIN_EMAIL_TWO = "OurSealTeamPro@gmail.com";
const test_email = "choyueh@uw.edu";

const FORMULA_ROW = 6;

// Base chance of remaining in lab
const STAY = 0.8;
// Lab score weight (chance to remain in lab = STAY - (WEIGHT - lab score)), this is defined by the last chance score (currently it is <70%)
const WEIGHT = 0.7;

let ss = SpreadsheetApp.openById(SEAL_LIFE_ID); // Seal clan life spreadsheet
let sb = SpreadsheetApp.openById(SANDBOX_ID); // SEAL sandbox spreadsheet
let associates = ss.getSheetByName("Associates"); // Seal clan life associates tab
let sandbox = sb.getSheetByName("Sandbox"); // SEAL sandbox sandbox tab
let sandbox_pass = associates.getRange("DZ:DZ").getValues().flat(); // SEAL clan life associates data in column DZ

let lab_status = associates.getRange("J:J").getValues().flat(); // Final verdict lab standing values
let handles = associates.getRange("A:A").getValues().flat(); // Quest handles
let emails = associates.getRange("AO:AO").getValues().flat(); // Emails
let names = associates.getRange("B:B").getValues().flat(); // Associate names
let task_status = associates.getRange("F:F").getValues().flat(); // Each member's tasks
let team_panels = associates.getRange("G:G").getValues().flat(); // Project quest pages
let lab_scores = associates.getRange("L:L").getValues().flat(); // Overall lab scores

let associates_col = associates.getLastColumn(); // Last SEAL clan life associates column
let formulas = associates.getRange(FORMULA_ROW, 1, 1, associates_col); // The 6th row of the SEAL clan life associates tab

// Establishes a list of column numbers in the 6th row of the SEAL clan life associates tab that have formulas
let avoid = [] 
for (let i = 1; i <= associates_col; i++) {
  if (formulas.getCell(1, i).getFormula() != "") {
    avoid.push(i);
  }
}

function main() {

  console.log("Start detecting: ");
  console.log();

  console.log("Start detetcing people with Last Chance & Sandbox status: ");
  lastChanceSandbox();
  console.log("Last Chance end");
  console.log();

  console.log("Start with detetcing people with DEAD task: ");
  deadTask();
  console.log("Dead task end");
  console.log();

  console.log("End");
}

// Sends a message to an admin to move the given remove_emails to the Sandbox Gmail group including the given reasons in the message
function notifyAdmin(remove_emails, reasons) {
  if (remove_emails.length != 0) {
    let admin_message = "SEND TO SANDBOX:\nPlease move those associates to Sandbox Gmail group due to " + reasons + ": \n";
    for (let i = 0; i < remove_emails.length; i++) {
      admin_message += remove_emails[i] + "\n";
    }
    try {
      SlackAPI.sendMessageToUser(ADMIN_EMAIL, admin_message);
      SlackAPI.sendMessageToUser(test_email, admin_message);
      MailApp.sendEmail(ADMIN_EMAIL_TWO,"SEAL Sandbox Notification", admin_message);
    } catch (e) {
      Logger.log('error with admin email (' + ADMIN_EMAIL + ').'+ e);
    } 
  }
}

// Finds people in SEAL Clan Life who have "Last Chance" or "Sandbox" status and either sends
// a warning message or moves them to the Sandbox and notifies an admin of who has been moved
function lastChanceSandbox() {
  let remove_emails = [];

  // The index of the value in the array would be one less than the index of the row
  for (let i = lab_status.length - 1; i >= START_ROW - 1; i--) { // Iterates through each person's row in SEAL Clan Life
    if (sandbox_pass[i] == "") {
      if (lab_status[i].includes('Last Chance') || lab_status[i].includes('Sandbox')) { // detect "Last Chance" Status at col J
        // Get information
        let email = emails[i];
        let name = names[i];
        let handle = handles[i];
        if (handle == "") {
          handle = name;
        }

        // Roll the dice
        let chance = STAY - (WEIGHT - lab_scores[i]);
        let dice = Math.random();
        console.log(chance);
        console.log(dice);
        if (dice > chance) { // get sandbox
          if (lab_status[i].includes('Last Chance')) { // Lab status is last chance
            console.log("Last Chance:\n" + name);

            // Creates a task in the Sandbox for the current person
            createTaskInSandbox(handle, "You have been put into the Sandbox because you were in \"Last Chance\" status on SEAL Life due to having empty cells and a low grade. | " + 
                                        "To return from Sandbox to SEAL Life, you have to complete one of the ToDo tasks assigned to \"Community\" in this spreadsheet. (Look for " + 
                                        "the name \"Community\" in Column H). Select the task you want and complete it. Do not edit the community task. Put your updates in this task. " + 
                                        "Reminder: it has to be a ToDo Community task, NOT an Icebox Community task."); 

            // Sends a slack message to the current person informing them they have been moved to the sandbox
            SlackAPI.sendMessageToUser(email, '** This is an automated message from Sudoku Bot. Please Do Not Reply ** \n\nDear member, your lab status in column J is "4. Last Chance" at ' + 
                                              'your row on SEAL Life Associates tab. We decide to move your row from SEAL Life to the Sandbox.\nYou can find more detail instruction ' + 
                                              'here: https://docs.google.com/document/d/1xgqrCGSCg6FAqOG58RmVEj9hmwFVZj7GMP7DcKJRCNQ/edit#\nIf there is any error, please report to ' + 
                                              'Benjamin via choyueh@uw.edu on Slack');
          } else if (lab_status[i].includes('Sandbox')) { // Lab status is Sandbox
            console.log("Sandbox:\n" + name);
            if (handle == "") {
              handle = name;
            }

            // Creates a task in the Sandbox for the current person
            createTaskInSandbox(handle, "You have been put into the Sandbox because your leader set your lab status to \"Sandbox\" on SEAL Life. | To return from Sandbox to SEAL Life, " + 
                                        "you have to complete one of the ToDo tasks assigned to \"Community\" in this spreadsheet. (Look for the name \"Community\" in Column H). Select " + 
                                        "the task you want and complete it. Do not edit the community task. Put your updates in this task. Reminder: it has to be a ToDo Community task, " + 
                                        "NOT an Icebox Community task");

            // Sends a slack message to the curent person informing them they are in the Sandbox
            SlackAPI.sendMessageToUser(email, '** This is an automated message from Sudoku Bot. Please Do Not Reply ** \n\nDear member, your lab status in column J is "Sandbox" at ' + 
                                              'your row on SEAL Life Associates tab. We decide to move your row from SEAL Life to the Sandbox.\nYou can find more detail instruction ' + 
                                              'here: https://docs.google.com/document/d/1xgqrCGSCg6FAqOG58RmVEj9hmwFVZj7GMP7DcKJRCNQ/edit#\nIf there is any error, please report to ' + 
                                             'Benjamin via choyueh@uw.edu on Slack');
          }
          console.log("Give " + name + " Sandbox task");
          console.log("Move " + name + " from associates to Sandbox");
          toSandbox(i);
          remove_emails.push(email);
        } else { // get reminder
        // Sends reminder message to the current person to avoid being moved to the Sandbox
          if (lab_status[i].includes("Last Chance")) {
            reminder(email, "Last Chance");
          } else if (lab_status[i].includes("Sandbox")) {
            reminder(email, "Sandbox");
          }
        }        

      }
    }
  
  }
  notifyAdmin(remove_emails, "Sandbox/Last Chance"); // Sends a message to an Admin to move emails to the Sandbox
}

// Finds people with dead tasks in SEAL Clan Life and either moves them to the Sandbox or sends them a reminder email
function deadTask() {
  let remove_emails = [];

  let stale = new RegExp("C T D R S\n([0-9]+ ){4}[^0][0-9]*", "i"); // Matches stale tasks

  // Iterates through every row of tasks in SEAL CLan Life
  for (let i = task_status.length - 1; i >= START_ROW - 1; i--) {
    // The index of the value in the array would be one less than the index of the row
    let handle = handles[i];
    if (handle == "") {
      handle = names[i];
    }
    if (sandbox_pass[i] == "") {
      if (stale.test(task_status[i])) { // Detects stale tasks

        // Trys to open the Quests tab in the team panels link associated with the current person
        try {
          SpreadsheetApp.openByUrl(team_panels[i]).getSheetByName("Quests");
        } catch (e) {
          Logger.log('error with handle (' + handle + ') workspace.'+ e);
          continue;
        }
        // The Quests tab in the team panels link for the current person
        let workspace = SpreadsheetApp.openByUrl(team_panels[i]).getSheetByName("Quests"); 
        let handle_col_num = workspace.getRange(1,1,1,workspace.getLastColumn()).getValues().flat().indexOf(handle) + 1; // Column of the current person in their team panel Quests tab
        let handle_col = [];
        if (handle_col_num == 0) {
          console.log("Didn't find " + handle + " in the corresponding workspace.");
        } else {
          handle_col = workspace.getRange(1,handle_col_num,workspace.getLastRow(),1).getValues().flat(); // Column of the current person in the Quests tab of their team panel
        }
        let task_place_link = workspace.getRange("C:C").getValues().flat(); // Links to tasks for different groups
        let task_place_name = workspace.getRange("D:D").getValues().flat(); // Names of the task places
        let quest_stale =  new RegExp("C T D R S M\n([0-9]+ ){4}[^0][ 0-9YN]+", "i"); // Matches stale Quests
        for (let j = 0; j < handle_col.length;j++) {
          let found_dead_task = false;
          if (quest_stale.test(handle_col[j])) { // Detects stale quests

            // Trys to open the link to the tasks for the stale quest
            try {
              SpreadsheetApp.openByUrl(task_place_link[j]).getSheetByName(task_place_name[j]);
            } catch (e) {
              Logger.log('error with link (' + task_place_link[j] + ').'+ e);
              continue;
            }
            let task_sheet = SpreadsheetApp.openByUrl(task_place_link[j]).getSheetByName(task_place_name[j]); // The sheet containing the stale quest
            let task_status = task_sheet.getRange("C:C").getValues().flat(); // Status' of all tasks in the sheet
            let task_num = task_sheet.getRange("B:B").getValues().flat(); // Numbers of all tasks in the sheet
            let task_handle = task_sheet.getRange("H:H").getValues().flat(); // Handles in the sheet
            // Iterates through each task in the sheet
            for (let k = 0; k < task_status.length; k++) {
              if (task_status[k] == "DEAD") {
                if (task_handle[k].includes(handle)) {
                  let email = emails[i];
                  let name = names[i];
                  let deadTaskMessage = "DEAD task:\n   [At " + task_place_link[j] + "] [Tab: " + task_place_name[j] + "] [Number: " + task_num[k] + "]";
                  console.log(deadTaskMessage);

                  // Roll the dice
                  let chance = STAY - (WEIGHT - lab_scores[i]);
                  let dice = Math.random();
                  console.log(chance);
                  console.log(dice);
                  if (dice > chance) { // get sandbox
                    console.log("DEAD task:\n" + name);
                    // Creates a task in the Sandbox for the current person because they have a DEAD task
                    createTaskInSandbox(handle, "You have been put into the Sandbox because you have a DEAD Task (details at the end of message). | To return from Sandbox to SEAL Life, you " + 
                                                "have to complete one of the ToDo tasks assigned to \"Community\" in this spreadsheet. (Look for the name \"Community\" in Column H). Select " + 
                                                "the task you want and complete it. Do not edit the community task. Put your updates in this task. Reminder: it has to be a ToDo Community " + 
                                                "task, NOT an Icebox Community task.\n" + deadTaskMessage);
                    // Sends a Slack message to the current person informing them they
                    // have been moved to the Sandbox because they had a dead task
                    SlackAPI.sendMessageToUser(email, '** This is an automated message from Sudoku Bot. Please Do Not Reply ** \n\nDear member, you have a DEAD task in your control panel ' + 
                                                      '(detail at the end of message). We decide to move your row from SEAL Life to the Sandbox.\nYou can find more detail ' + 
                                                      'instruction here: https://docs.google.com/document/d/1xgqrCGSCg6FAqOG58RmVEj9hmwFVZj7GMP7DcKJRCNQ/edit#\nIf there is ' + 
                                                      'any error, please report to Benjamin via choyueh@uw.edu on Slack.\n' + deadTaskMessage);
                    console.log("Move " + name + " from associates to Sandbox");
                    toSandbox(i); // Move the person's row in SEAL Clan Life to the SEAL Sandbox
                    remove_emails.push(email);
                  } else { // get reminder
                    reminder(email, deadTaskMessage);
                  }

                  found_dead_task = true;            
                  break;
                }
              }
            }
          }
          if (found_dead_task) {
            break;
          }
        }
      }
    }  
  }
  notifyAdmin(remove_emails, "DEAD task"); // Notifies an admin of the people moved to the Sandbox
}

// Creates a new task in the Sandbox Kanban tab for the given handle for the given reason
function createTaskInSandbox(handle, reason) {
  let sb_kanban = sb.getSheetByName("Kanban"); // Sandbox Kanban tab
  sb_kanban.insertRowBefore(SANDBOX_START_ROW); // Insert row before the 7th row
  let range = sb_kanban.getRange(SANDBOX_START_ROW - 1, 1, 1, sb.getLastColumn()); // Row that was inserted
  let copyRange = sb_kanban.getRange(SANDBOX_START_ROW, 1, 1, sb_kanban.getLastColumn()); // Copy of range
  range.copyTo(copyRange);
  let newTaskNumber = getNewTaskNumber(); // New task number
  let dashboardLink = sandbox.getRange(9, 33); // Dashboard link 

  sb_kanban.getRange(SANDBOX_START_ROW, 2).setValue(newTaskNumber); // Column B is the new task number
  sb_kanban.getRange(SANDBOX_START_ROW, 6).setValue("1. To Do"); // Column F is the status of the task
  sb_kanban.getRange(SANDBOX_START_ROW, 7).setValue("Sudokubot"); // Column G is who the task was given from
  sb_kanban.getRange(SANDBOX_START_ROW, 8).setValue(handle); // Column H is the given handle of the person to be assigned the task
  sb_kanban.getRange(SANDBOX_START_ROW, 9).setValue(reason); // Column I is the given reason for the task
  sb_kanban.getRange(SANDBOX_START_ROW, 13).setValue(new Date()); // Column M is the date added
  sb_kanban.getRange(SANDBOX_START_ROW, 14).setValue(new Date()); // Column N is the last modify added date
  if (dashboardLink.getValue() != "") {
    sb_kanban.getRange(SANDBOX_START_ROW, 20).setValue(dashboardLink.getRichTextValue().getLinkUrl()); // Column T is the dashboardlink
  }
}

// Returns a new task number
function getNewTaskNumber() {
  let vals = sb.getRange("B7:B").getValues();
  let max = -1;
  for (let i = 0; i < vals.length; i++) {
    let num = parseInt(vals[i][0].substring(1));
    if (num > max) {
      max = num;
    }
  }
  console.log(max);
  let newT = "T" + (max + 1);
  console.log(newT);
  return newT;
}

// Moves the given index + 1 row in SEAL Clan Life to the Sandbox
function toSandbox(index) {
  let row = index + 1;
  sandbox.insertRowBefore(START_ROW);

  let start = 1;
  for (let i = 0; i < avoid.length; i++) {
    if (start != avoid[i]) {
      let range = associates.getRange(row, start, 1, avoid[i] - start);
      sandbox.getRange(START_ROW, start, 1, avoid[i] - start).setValues(range.getValues());
      start = avoid[i] + 1;
    }
  }
  let range = associates.getRange(row, start, 1, associates_col);
  sandbox.getRange(START_ROW, start, 1, associates_col).setValues(range.getValues());

  associates.deleteRow(row);
  associates.insertRowAfter(ss.getLastRow());
}

// Sends a slack message to the person with the given email explaining why they are in the 
// Sandbox or may be moved there in the future and what they can do to avoid the Sandbox
function reminder(email, reason) {
  if (reason.includes("Last Chance")) {
    SlackAPI.sendMessageToUser(email, "** This is an automated message from Sudoku Bot. Please Do Not Reply ** \n\nDear member, you are very close to getting Sandbox! Luckily, you recieved " +
                                      "a Sandbox Pass from Sudokubot for you to fix your lab status and avoid being Sandboxed in the future. Please address the following problem ASAP to " +
                                      "avoid being moved to Sandbox:\n Your Lab score on SEAL Clan Life are currently lower than 70%. Please check the following to improve your lab score:\n " +
                                      "1) Did you check in recently?\n 2) Is your weekly average hours greater than 10?\n 3) Is all your mission table filled out (See Mission Table score to " + 
                                      "confirm.)\n 4) Is your YBR Delta 0? (0 YBR Delta will minus 10% from your overall score, please reach out to your team leader for YBR tasks.)\n 5) Is your " +
                                      "onboarding score 100%?");
  } else if (reason.includes("Sandbox")) {
    SlackAPI.sendMessageToUser(email, "** This is an automated message from Sudoku Bot. Please Do Not Reply ** \n\nDear member, you are very close to getting Sandbox! Luckily, you recieved " +
                                      "a Sandbox Pass from Sudokubot for you to fix your lab status and avoid being Sandboxed in the future. Please address the following problem ASAP to " +
                                      "avoid being moved to Sandbox:\n Your lab status are currently in Sandbox. The most common reason for this situation is when you did not fill out your " +
                                      "report on time. Report are due on 5 pm a day before the actual meeting. Please reach out to your team leader and make up your report as soon as possible.");
  } else if (reason.includes("DEAD task")) {
    SlackAPI.sendMessageToUser(email, "** This is an automated message from Sudoku Bot. Please Do Not Reply ** \n\nDear member, you are very close to getting Sandbox! Luckily, you recieved " +
                                      "a Sandbox Pass from Sudokubot for you to fix your lab status and avoid being Sandboxed in the future. Please address the following problem ASAP to " +
                                      "avoid being moved to Sandbox:\n You currently have a DEAD task in your control panel, the details are as follow:\n" +  reason + ".\nPlease remeber " +
                                      "to update this task. Sudokubot only catch one of your DEAD tasks, so please also check for other Stale task to fully address the problem.");
  }
}

// Sends an email to OurSealTeamPro@gmail.com notifying them to move associates to the Sandbox Gmail group
function test() {
  MailApp.sendEmail("OurSealTeamPro@gmail.com","SEAL Sandbox Notification", "Please move those associates to Sandbox Gmail group: \ntest@gmail.com" );

}
