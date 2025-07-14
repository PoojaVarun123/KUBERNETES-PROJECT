1) GitHub is a hosting service for Git repositories online.

2) Git
  -  Git is a decentralized version control system to manage source code history. 
  -  decentralized > open source code management tool > version control system > enables collaboration, parallel development, manages source code history


3) git branching strategy > gitflow model
   main > permanent
   develop > permanent -- staging/QA
        feature-1
        feature-2
        release -- PRODUCT
        bugfix
        hotfix 

4) git stash - temporarily save uncommitted changes (both the staged and unstaged without committing, 
             - So we can work on switching to other branches with a clean working directory
  list: list all stashes
  pop: restore recent stash > removes from the stash list
  apply: git stash apply stash@{1}
      -restore recent stash or a specific one  > keeps in stash list
  drop: git stash > delete a stash

5) git pull >  downloads changes to local repo + incorporates changes
    -  git pull origin main
    -  git pull origin feature-branch

6) git push > move changes to the remote repo
    - git push origin feature-branch
    - git push origin main

7) git fetch >  downloads the changes from the remote repo

8) git merge > be on the branch you want to merge into
  - git checkout main
  - git pull origin main
  - git merge feature-branch
  - git push origin main
 
9)  git rebase > linearizes the history  >  be on the branch you wnat to rebase onto another > best for cleaning up local commits before merging
  - git checkout feature
  - git rebase main

  - git rebase --continue > when conflicts
  - git rebase --abort

  - git rebase -i HEAD~3 (squash, edit,drop)
  - after rebase use > git push --force

10) git clone > to download a copy of the existing remote repo  > git clone <url>

11) git remote > manages remote connections(URL'S) to repositories hosted online
  - git remote -v > show all remotes and their fetch/push URLs
  - git remote add origin <url>
  - git remote rename origin <url>
  - git remote remove origin 
  - git remote show origin 
  - git remote set-url origin  <new url> >  replace the url

12) git config > sets git configuration values like username, email, and default editor
     - git config --global user.name 
     - git config --global user.email
     - git config --global core.editor
     - git confif --list
     - set config for only current repo: this overrides the global setting, but only inside th current repo > git config user.name 

13) git add >  moves to the staging area
  - git add .
  - git add file.txt
  - git add /src/

14) git commit  > saves a version of saved changes > Saves a snapshot of your staged changes to the Git history.
  - saves to git history
  - takes the staged changes and saves them as a snapshot in git history with a message

15) git squash 
  - git rebase HEAD ~3

16) git cherry-pick > git cherry-pick copies a single commit (or multiple commits) from one branch and applies it to your current branch.
    - git checkout main
    - git cherry-pick commit-id

17) git checkout  > to create and switch
      - git switch -b new-branch
      
18) git blame > Shows who made each line change in a file and when >  Useful for tracking who changed what and why.
      - git blame index.html

19) git diff > Shows the line-by-line differences between:

-Working dir vs staged
-One commit vs another
-Two branches

git diff                # unstaged changes
git diff --staged       # staged changes
git diff main dev       # between branches


20) git restore > unstage : git add undo
    - File added (git add) >  git restore --staged file.txt Unstages the file
    - File added + modified git restore file.txt Undoes file changes (⚠️ irreversible)

21) git revert > undo push
 Commit pushed git revert <commit-id> Undo with a new commit (safe way)
 Commit pushed git reset --hard HEAD~1 + push --force Rewrite history (⚠️ use with caution)

22) git reset  >  git commit and push undo
File committed git reset --soft HEAD~1 Undo commit, keep changes staged
File committed git reset --mixed HEAD~1 Undo commit, keep changes in working dir
File committed git reset --hard HEAD~1 Undo commit + delete changes

21) git log  > Shows a list of all commits in the repo's history.
    - git log --oneline

22) branching > A branching strategy is a standard way your team organizes and uses Git branches to manage features, 
  bug fixes, and releases in a clean, controlled, and scalable way.
  -Prevents code conflicts - Keeps history clean - Enables collaboration - Supports CI/CD pipelines - Ensures code stability before release
    git checkout main
    git pull origin main
    git checkout -b feature-branch
    git push origin feature-branch

23) merging >
 
24) PR > collaboration workflow > request to merge code from one branch into another
   - A GitHub/GitLab/Bitbucket feature. Let you:
            -Propose code changes
            -Review changes with the team
            -Discuss and merge

25) How does Git work? > git add > git commit > git push

26) git status > Shows the current state of the working directory: What’s modified - What’s staged - What’s untracked

27) conflict 
   - Occurs when two branches modify the same part of a file differently, and Git can’t decide which to keep.
   - How to fix:
         -Git marks the file with <<<<, ====, >>>>
         -You edit manually, then run:
             -git add .
             -git commit     # for merge conflict
             -git rebase --continue  # for rebase conflict
 


















