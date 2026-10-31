# Sending playtest logs to Google Drive

At the end of a playthrough the game uploads its playtest log to one Google
Drive folder. Each file is numbered in the order it arrives:

```
001_2026-10-30_14-05-22_Windows.jsonl
002_2026-10-30_14-31-09_Web.jsonl
```

The time is when the log arrived, in the script's time zone. If the upload
fails (no internet), the end screen offers a download instead, like before.

## Setup (once, by the folder owner)

1. In Google Drive, make a folder for the logs (e.g. *Eyewitless playtest
   logs*). Open it and copy the ID from the address bar: the part after
   `/folders/`.
2. Go to <https://script.google.com>, click **New project**, and name it
   *Eyewitless log uploader*.
3. Delete the code there and paste in everything from
   `tools/playtest_upload.gs`. Set `FOLDER_ID` to the folder ID only (like
   `1x7DqVO_C-hkCGI5iHj8fEANqCpzO6btc`), not the whole link. Save.
4. Click **Deploy → New deployment**. Pick type **Web app**.
   - Execute as: **Me**
   - Who has access: **Anyone** (testers aren't signed in to Google)
5. Click **Deploy**, allow the permissions it asks for (it needs to create
   files in your Drive), and copy the **Web app URL** (ends in `/exec`).
6. In `scripts/event_log.gd`, paste the URL into `upload_url`:
   ```gdscript
   var upload_url := "https://script.google.com/macros/s/.../exec"
   ```
7. Export the web build again so testers get the new version.

To share the logs with the team, share the Drive folder as usual.

## Good to know

- Anyone who digs the URL out of the game can add files to that folder.
  They **can't** read, change or delete anything. The script only accepts
  logs under 1 MB that look like game logs.
- The logs hold what the player clicked and chose, with timestamps. No names
  or personal details. Still, tell testers their play is recorded.
- If you edit the script later, use **Deploy → Manage deployments → Edit →
  New version**, so the URL stays the same.
- To restart numbering at 001: in the script editor, **Project settings →
  Script properties**, delete `count`.
- A tester who closes the game before the end sends nothing (the log stays on
  their computer in `user://playtest_logs/`).
