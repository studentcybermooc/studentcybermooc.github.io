#!/usr/bin/env sh

# add PUBLISH_FOLDER to your .gitignore

REMOTE="origin"
BRANCH="gh-pages"
PUBLISH_FOLDER="public"

if ! git diff-files --quiet --ignore-submodules --
then
    echo "The working directory is dirty. Please commit any pending changes."
    exit 1;
fi
echo "Switching to master branch"
git checkout master

echo "Preparing publish folder"
rm -rf ${PUBLISH_FOLDER} && mkdir ${PUBLISH_FOLDER}
git worktree prune
echo "Checking out ${BRANCH} branch into the publish folder"
git worktree add -B ${BRANCH} ${PUBLISH_FOLDER} --no-checkout

echo "Generating site"
hugo

echo "Updating ${BRANCH} branch"
cd ${PUBLISH_FOLDER} && git add --all && git commit -m "Updating gh-pages (publish.sh)" && cd ..

echo "Pushing to ${REMOTE}"
git push ${REMOTE} +${BRANCH}

echo "Cleaning up"
rm -rf ${PUBLISH_FOLDER}