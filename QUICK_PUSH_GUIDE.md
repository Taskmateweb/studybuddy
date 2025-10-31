# Quick Push Guide - Taskmateweb Organization

## 🚀 Steps to Push StudyBuddy to Taskmateweb Organization

### 1. Create Repository on GitHub

1. Go to: https://github.com/orgs/Taskmateweb/repositories
2. Click **"New repository"** (green button)
3. Settings:
   - Owner: **Taskmateweb**
   - Repository name: **studybuddy**
   - Description: **"A modern study management app built with Flutter and Firebase"**
   - Visibility: **Public**
   - ❌ DON'T check "Add a README file"
   - ❌ DON'T add .gitignore
   - ❌ DON'T choose a license
4. Click **"Create repository"**

---

### 2. Push Your Code

Open PowerShell in your project directory and run these commands:

```powershell
# Navigate to your project
cd E:\flutterProject\studybuddy

# Initialize Git (if not already done)
git init

# Add all files
git add .

# Create first commit
git commit -m "Initial commit: StudyBuddy v1.0.0

- Complete authentication system with Firebase
- Task management with CRUD operations
- Modern UI with Material 3 design
- Real-time data synchronization
- Celebration animations on task completion
- Priority-based task organization
- Category-based task filtering
- Study statistics dashboard
- 7-day streak tracking"

# Rename branch to main
git branch -M main

# Add remote repository (Taskmateweb organization)
git remote add origin https://github.com/Taskmateweb/studybuddy.git

# Push to GitHub
git push -u origin main
```

---

### 3. If You Need Authentication

If prompted for credentials, use a **Personal Access Token**:

1. Go to: https://github.com/settings/tokens
2. Click **"Generate new token"** → **"Generate new token (classic)"**
3. Settings:
   - Note: `StudyBuddy - Taskmateweb`
   - Expiration: `90 days` (or your preference)
   - Scopes: Check **`repo`** (Full control of private repositories)
4. Click **"Generate token"**
5. **Copy the token** (you won't see it again!)
6. When pushing, use:
   - Username: `rakibul414`
   - Password: `<paste your token here>`

---

### 4. Verify Upload

1. Go to: https://github.com/Taskmateweb/studybuddy
2. You should see all your files! ✅
3. Check that:
   - README.md displays properly
   - All folders are there (lib, android, ios, etc.)
   - .gitignore is working (no build/ folder)

---

### 5. Final Setup on GitHub

#### Add Topics
1. On your repository page, click **"⚙️ Settings"** near the top
2. Under "About", click the gear icon
3. Add topics:
   ```
   flutter, dart, firebase, android, ios, study-app, 
   task-management, material-design, mobile-app, 
   productivity, student-app
   ```
4. Click **"Save changes"**

#### Update Description
In the same "About" section:
- Website: (leave empty or add if you deploy web version)
- Description: "📚 A modern study management app built with Flutter and Firebase"
- Check ☑️ "Include in the home page"

#### Enable Features
1. In repository Settings
2. Under "Features", enable:
   - ✅ Issues
   - ✅ Discussions (optional)
   - ✅ Projects (optional)

---

### 6. Create Your First Release

```powershell
# Tag the release
git tag -a v1.0.0 -m "Release v1.0.0 - Initial stable release"

# Push the tag
git push origin v1.0.0
```

Then on GitHub:
1. Go to **Releases** tab
2. Click **"Create a new release"**
3. Choose tag: **v1.0.0**
4. Release title: **StudyBuddy v1.0.0 - Initial Release**
5. Description: Copy from CHANGELOG.md
6. Attach the APK file: `build\app\outputs\flutter-apk\app-release.apk`
7. Click **"Publish release"**

---

## 🎉 Done!

Your repository is now live at:
**https://github.com/Taskmateweb/studybuddy**

### Next Steps:
- [ ] Add screenshots to README
- [ ] Star your own repository ⭐
- [ ] Share with your team
- [ ] Set up branch protection rules (optional)
- [ ] Add collaborators if needed

---

## 📝 Common Commands

```powershell
# Check status
git status

# Add new changes
git add .
git commit -m "feat: Add new feature"
git push

# Pull latest changes
git pull origin main

# View commit history
git log --oneline

# Create new branch
git checkout -b feature/new-feature

# Switch branch
git checkout main
```

---

## 🆘 Troubleshooting

### "Repository not found"
- Make sure repository is created in Taskmateweb organization
- Check URL: `https://github.com/Taskmateweb/studybuddy.git`

### "Permission denied"
- Use Personal Access Token instead of password
- Make sure you're a member of Taskmateweb organization

### "Failed to push"
```powershell
git pull origin main --rebase
git push origin main
```

### "Large files warning"
- Check .gitignore includes build/ and .dart_tool/
- Run: `git rm -r --cached build/`

---

**Author**: Rakibul Islam (@rakibul414)  
**Organization**: [Taskmateweb](https://github.com/Taskmateweb)  
**Repository**: https://github.com/Taskmateweb/studybuddy
