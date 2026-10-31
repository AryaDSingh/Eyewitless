// Eyewitless playtest log uploader (Google Apps Script).
// Receives a playtest log from the game and saves it in one Google Drive
// folder as 001_2026-10-30_14-05-22_Windows.jsonl, 002_..., and so on.
// Setup steps: docs/PLAYTEST_UPLOAD.md

// Only the part of the folder's link after /folders/, not the whole link.
const FOLDER_ID = '1x7DqVO_C-hkCGI5iHj8fEANqCpzO6btc';
// Logs are a few KB; anything bigger isn't from the game.
const MAX_CHARS = 1000000;

function doPost(e) {
  const body = e.postData ? e.postData.contents : '';
  if (!body || body.length > MAX_CHARS || body.trim().charAt(0) !== '{') {
    return ContentService.createTextOutput('rejected');
  }
  // One upload at a time, so two testers finishing together never get the same number.
  const lock = LockService.getScriptLock();
  lock.waitLock(20000);
  try {
    const props = PropertiesService.getScriptProperties();
    const number = Number(props.getProperty('count') || 0) + 1;
    const stamp = Utilities.formatDate(new Date(), Session.getScriptTimeZone(), 'yyyy-MM-dd_HH-mm-ss');
    const platform = String((e.parameter && e.parameter.platform) || 'unknown').replace(/[^A-Za-z0-9]/g, '');
    const name = String(number).padStart(3, '0') + '_' + stamp + '_' + platform + '.jsonl';
    DriveApp.getFolderById(FOLDER_ID).createFile(name, body, MimeType.PLAIN_TEXT);
    // Count only after the file is saved, so a failed upload doesn't skip a number.
    props.setProperty('count', String(number));
    return ContentService.createTextOutput('ok ' + name);
  } finally {
    lock.releaseLock();
  }
}
