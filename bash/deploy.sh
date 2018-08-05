#!/bin/bash

# get a version from POM
current_version=$(mvn help:evaluate -Dexpression=project.version | grep -e '^[^\[]')
echo current_version=$current_version
# remove -SNAPSHOT from version
clean_version=$(echo $current_version | sed -e "s/-SNAPSHOT//g")
echo clean_version=$clean_version
# get the latest tag starting with clean_version from the repo
last_tag=$(git tag --list --sort=committerdate "$clean_version-RC_*" | tail -1)
echo last_tag=$last_tag
if [[ $last_tag = $clean_version-RC_* ]]; then
    # if there is such tag, get it's number
    last_rc_version=$(echo $last_tag | cut --delimiter=_ --fields=2)
else
    # if not, just init it
    last_rc_version=0
fi
echo last_rc_version=$last_rc_version;
# get the number of new rc
new_rc_version=$(expr $last_rc_version + 1)
echo new_rc_version=$new_rc_version
# prepare the name of the new tag
rc_tag=$clean_version-RC_$new_rc_version
echo rc_tag=$rc_tag

# create a tag
git tag $rc_tag

git push origin $rc_tag

# change version in POM to rc_tag
mvn versions:set -DnewVersion=$rc_tag

rm *versionsBackup

# deploy with new version
mvn clean deploy:deploy