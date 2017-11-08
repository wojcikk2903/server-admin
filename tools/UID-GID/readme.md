# Project sync UIDs & GIDs across all servers
1. There are all servers and their users and groups on https://docs.google.com/spreadsheets/d/1cILydiQqcegfRs_ce0X5y3cZ5wYrMX6-RcGv79azjKQ/edit#gid=416870962
2. A server that does not have same UID for user 'lab' (for example)  
3. Find new UID & GID in the spreadsheet (1000 for user 'lab')
4. Connect via SSH to the target server and execute 'id lab'
5. You uid=1004(lab) gid=1004(lab) groups=1004(lab)
6. Copy scripts changeUID.sh and changeGID.sh from Github to the target server into /root folder
7. Make them executable 'chmod +x *.sh'
8. Run: changeUID.sh lab 1004 1000
9. Run: changeGID.sh lab 1004 1000
10. Check id lab again
11. Check files and folders owned by user 'lab' with 'ls lan' or 'find / -uid 1000'
12. Repeat it for all users with wrong UIDs&GIDs on all servers
