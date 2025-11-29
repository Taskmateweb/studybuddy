# Firebase Index Fix for Stats Screen

## The Issue
The stats screen requires 2 Firestore composite indexes:
1. **Focus Sessions**: Query by `userId` and `startTime`
2. **Activities**: Query by `userId` and `date` 

## Quick Solution - Click These Links

### 1. Focus Sessions Index
Click this link to auto-create the index:
```
https://console.firebase.google.com/v1/r/project/studybuddy-cc83d/firestore/indexes?create_composite=Cldwcm9qZWN0cy9zdHVkeWJ1ZGR5LWNjODNkL2RhdGFiYXNlcy8oZGVmYXVsdCkvY29sbGVjdGlvbkdyb3Vwcy9mb2N1c19zZXNzaW9ucy9pbmRleGVzL18QARoKCgZ1c2VySWQQARoNCglzdGFydFRpbWUQAhoMCghfX25hbWVfXxAC
```

### 2. Activities Index  
Click this link to auto-create the index:
```
https://console.firebase.google.com/v1/r/project/studybuddy-cc83d/firestore/indexes?create_composite=ClNwcm9qZWN0cy9zdHVkeWJ1ZGR5LWNjODNkL2RhdGFiYXNlcy8oZGVmYXVsdCkvY29sbGVjdGlvbkdyb3Vwcy9hY3Rpdml0aWVzL2luZGV4ZXMvXxABGgoKBnVzZXJJZBABGggKBGRhdGUQARoMCghfX25hbWVfXxAB
```

## Alternative: Deploy from firestore.indexes.json

```bash
firebase deploy --only firestore:indexes
```

## Wait Time
Index creation takes 2-5 minutes. You'll see "Building" status in Firebase Console.

## After Indexes are Ready
1. Hot restart your app (press `R` in terminal or stop and rerun)
2. Navigate to Stats screen  
3. All sections should load without errors

## What These Indexes Do

**Focus Sessions Index:**
- Filters by current user
- Filters by today's date
- Orders by time (newest first)

**Activities Index:**
- Filters by current user  
- Filters by date range (last 7 days for weekly trend)
- Orders chronologically

Both are required for the stats screen to function properly.
