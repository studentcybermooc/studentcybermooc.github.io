---
title: "Introduction_git"
description: ""
date: 2018-09-14
githubIssueID: 0
tags: [""]
draft: true
---


https://dev.to/shreyasminocha/how-i-do-my-git-commits-34d

* specify git editor
core.editor "subl -n -w"

---

https://vickylai.com/verbose/interactive-pre-commit-hook-checklist/

---

https://www.atlassian.com/git/tutorials/comparing-workflows/feature-branch-workflow

Git Feature branch workflow

---

https://www.atlassian.com/git/tutorials/comparing-workflows/gitflow-workflow

git branch develop
git push -u origin develop

Creating a feature branch

	Without the git-flow extensions:

		git checkout develop
		git checkout -b feature_branch

	When using the git-flow extension:

		git flow feature start feature_branch

Finishing a feature branch

	Without the git-flow extensions:

		git checkout develop
		git merge feature_branch

	Using the git-flow extensions:

		git flow feature finish feature_branch

Creating Release Branches

	Without the git-flow extensions:

		git checkout develop
		git checkout -b release/0.1.0

	When using the git-flow extensions:

		$ git flow release start 0.1.0
		Switched to a new branch 'release/0.1.0'

Finishing Release Branches

	Without the git-flow extensions:

		git checkout develop
		git merge release/0.1.0

	Or with the git-flow extension:

		git checkout master
		git checkout merge release/0.1.0
		git flow release finish '0.1.0'

Hotfix Branches

	Creating Hotfix Branches

		Without the git-flow extensions:

			git checkout master
			git checkout -b hotfix_branch

		When using the git-flow extensions: 

			git flow hotfix start hotfix_branch

	Finishing Hotfix Branches

		Without the git-flow extensions:

			git checkout master
			git merge hotfix_branch
			git checkout develop
			git merge hotfix_branch
			git branch -D hotfix_branch

		When using the git-flow extensions: 

			git flow hotfix finish hotfix_branch



The overall flow of Gitflow is:

A develop branch is created from master
A release branch is created from develop
Feature branches are created from develop
When a feature is complete it is merged into the develop branch
When the release branch is done it is merged into develop and master
If an issue in master is detected a hotfix branch is created from master
Once the hotfix is complete it is merged to both develop and master


---

git config --global alias.plog "log --graph --pretty=format:'%h -%d %s %n' --abbrev-commit --date=relative --branches" -> git plog

les variables git
user.email ""
user.name ""

http://blog.izs.me/post/37650663670/git-rebase : lu, à résumer vite fait

https://sandofsky.com/blog/git-workflow.html : lu

If you’re fighting Git’s defaults, ask why.

Treat public history as immutable, atomic, and easy to follow. Treat private history as disposable and malleable.

The intended workflow is:

1. Create a private branch off a public branch.
2. Regularly commit your work to this private branch.
3. Once your code is perfect, clean up its history.
4. Merge the cleaned-up branch back into the public branch.


https://vickylai.com/verbose/git-commit-practices-your-future-self-will-thank-you-for/

git reset

> in a branch ie "new-feature"
```
git reset --soft HEAD~5
git commit -m "New message for the combined commit"
git merge master
```

git rebase.

This is appropriate when:
- We want to squash only some commits
- We want to edit previous commit messages
- We want to delete or reorder specific commits

git stash.




https://www.atlassian.com/git

https://www.atlassian.com/git/tutorials/comparing-workflows

https://trunkbaseddevelopment.com/short-lived-feature-branches/

---

https://heronebag.com/blog/how-do-i-start.../