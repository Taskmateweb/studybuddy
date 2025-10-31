# How to Push StudyBuddy to GitHub

Follow these steps to push your project to GitHub.

## Step 1: Create a GitHub Repository in Your Organization

1. Go to your organization: [Taskmateweb](https://github.com/orgs/Taskmateweb/repositories)
2. Click the "New repository" button (green button)
3. Fill in the details:
   - **Owner**: Select "Taskmateweb" (your organization)
   - **Repository name**: `studybuddy`
   - **Description**: "A modern study management app built with Flutter"
   - **Visibility**: Public (recommended for open source)
   - **DO NOT** check "Initialize this repository with a README" (we already have one)
   - **DO NOT** add .gitignore or license (we already have them)
4. Click "Create repository"

## Step 2: Prepare Your Local Repository

Open PowerShell in your project directory:

```powershell
cd E:\flutterProject\studybuddy
```

## Step 3: Initialize Git (if not already done)

Check if Git is initialized:
```powershell
git status
```

If you see "fatal: not a git repository", initialize it:
```powershell
git init
```

## Step 4: Add All Files

```powershell
# Add all files to staging
git add .

# Check what will be committed
git status
```

## Step 5: Create Your First Commit

```powershell
git commit -m "Initial commit: StudyBuddy v1.0.0 with task management and Firebase integration"
```

## Step 6: Add Remote Repository

Add your organization repository as the remote:

```powershell
git remote add origin https://github.com/Taskmateweb/studybuddy.git
```

Verify the remote was added:
```powershell
git remote -v
```

You should see:
```
origin  https://github.com/Taskmateweb/studybuddy.git (fetch)
origin  https://github.com/Taskmateweb/studybuddy.git (push)
```

## Step 7: Push to GitHub

```powershell
# Push to main branch
git push -u origin main
```

If you get an error about `master` vs `main`, try:
```powershell
git branch -M main
git push -u origin main
```

### If prompted for credentials:

**Option 1: Personal Access Token (Recommended)**
1. Go to GitHub Settings → Developer settings → Personal access tokens → Tokens (classic)
2. Click "Generate new token (classic)"
3. Give it a name like "StudyBuddy"
4. Select scopes: `repo` (full control)
5. Click "Generate token"
6. Copy the token (you won't see it again!)
7. Use the token as your password when pushing

**Option 2: GitHub CLI**
```powershell
# Install GitHub CLI first
winget install --id GitHub.cli

# Authenticate
gh auth login

# Push
git push -u origin main
```

## Step 8: Verify on GitHub

1. Go to `https://github.com/Taskmateweb/studybuddy`
2. Refresh the page
3. You should see all your files!
4. The repository will be under the Taskmateweb organization

## Step 9: Update README with Your Info

Don't forget to update the README.md with:
- Your GitHub username
- Your email
- Your name
- Repository URL

```powershell
# Edit README.md
code README.md

# Commit changes
git add README.md
git commit -m "docs: Update README with personal information"
git push
```

---

## Common Issues and Solutions

### Issue 1: "Permission denied"
**Solution:** Use Personal Access Token instead of password

### Issue 2: "Repository not found"
**Solution:** 
- Check the repository URL
- Ensure the repository exists on GitHub
- Verify your username in the URL

### Issue 3: "Failed to push some refs"
**Solution:**
```powershell
git pull origin main --rebase
git push origin main
```

### Issue 4: "Large files warning"
**Solution:**
```powershell
# Add files to .gitignore that shouldn't be committed
echo "build/" >> .gitignore
echo ".dart_tool/" >> .gitignore
git rm -r --cached build/
git rm -r --cached .dart_tool/
git commit -m "Remove build artifacts"
git push
```

---

## Files That Should NOT Be Pushed

Make sure your `.gitignore` includes:
```
# Build outputs
build/
*.apk
*.aab
*.ipa

# Dependencies
.dart_tool/
.packages
.pub-cache/
.pub/

# IDE
.idea/
.vscode/
*.iml
*.swp

# Firebase (optional - don't commit if you want to keep them private)
# android/app/google-services.json
# ios/Runner/GoogleService-Info.plist

# Environment variables
.env
.env.local
```

---

## Creating Releases

### Tag a Release
```powershell
git tag -a v1.0.0 -m "Release version 1.0.0"
git push origin v1.0.0
```

### Create GitHub Release
1. Go to your repository on GitHub
2. Click "Releases" → "Create a new release"
3. Choose your tag: `v1.0.0`
4. Release title: "StudyBuddy v1.0.0 - Initial Release"
5. Add description from CHANGELOG.md
6. Attach APK/AAB files if desired
7. Click "Publish release"

---

## Branching Strategy

### Create Feature Branch
```powershell
git checkout -b feature/focus-mode
# Make changes
git add .
git commit -m "feat: Add focus mode with Pomodoro timer"
git push origin feature/focus-mode
```

### Create Pull Request
1. Go to GitHub repository
2. Click "Pull requests" → "New pull request"
3. Select your branch
4. Add description
5. Click "Create pull request"

---

## Keeping Your Repo Updated

### After making changes:
```powershell
# Check status
git status

# Add changes
git add .

# Commit with meaningful message
git commit -m "feat: Add new feature"

# Push to GitHub
git push
```

### Pull latest changes:
```powershell
git pull origin main
```

---

## Repository Settings

### Enable Issues
1. Go to repository Settings
2. Check "Issues" in Features section

### Add Topics
1. Go to repository main page
2. Click "Add topics"
3. Add: `flutter`, `firebase`, `study-app`, `task-management`, `android`, `ios`, `material-design`

### Add Description
Click "Edit" next to your repository name and add:
"📚 A modern study management app built with Flutter and Firebase"

### Add Website (optional)
If you deploy a web version, add the URL

---

## Next Steps

1. ✅ Repository is now on GitHub!
2. 🌟 Add a nice banner image to README
3. 📸 Add screenshots to the repository
4. 🏷️ Create your first release
5. 📢 Share your project!

---

## Useful Git Commands Reference

```powershell
# View commit history
git log --oneline

# Undo last commit (keep changes)
git reset --soft HEAD~1

# Discard all local changes
git reset --hard

# Create and switch to new branch
git checkout -b branch-name

# Switch branches
git checkout main

# Delete branch
git branch -d branch-name

# View all branches
git branch -a

# View remote URLs
git remote -v

# Update remote URL
git remote set-url origin https://github.com/username/repo.git
```

---

**Congratulations! Your project is now on GitHub!** 🎉

Don't forget to:
- Update your profile README
- Share the repository link
- Add a star to your own project ⭐
- Invite collaborators if needed

Happy coding! 🚀
