#!/bin/sh

if ! git diff-files --quiet --ignore-submodules --if [[ $(git status -s) ]]
then
    echo "The working directory is dirty. Please commit any pending changes."
    exit 1;
fi

echo "Switching to master branch"
echo "If you're using git flow, please make sure master branch is up to date."
git checkout master

echo "Deleting old publication"
rm -rf public
mkdir public
git worktree prune
rm -rf .git/worktrees/public/

echo "Checking out gh-pages branch into public"
git worktree add -B gh-pages public origin/gh-pages

echo "Removing existing files"
rm -rf public/*

echo "Generating site"
hugo

echo "Writing CNAME file"
echo studentcybermooc.com >> public/CNAME

echo "Updating gh-pages branch"
cd public && git add --all && git commit -m "Publishing to gh-pages (publish.sh)" && cd ..

echo "Pushing to github"
git push origin gh-pages