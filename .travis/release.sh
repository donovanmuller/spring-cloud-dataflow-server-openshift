#! /bin/bash
set -e

# Install github_changelog_generator
gem install github_changelog_generator

# Generate CHANGELOG.md
echo -e "\033[0;32mGenerating CHANGELOG...\033[0m"
github_changelog_generator -t ${GITHUB_ACCESS_TOKEN}

# Commit and push the CHANGELOG
git config --global user.email "builds@travis-ci.com"
git config --global user.name "Travis CI"
git remote rm origin
git remote add origin https://${GITHUB_USERNAME}:${GITHUB_ACCESS_TOKEN}@github.com/${GITHUB_USERNAME}/spring-cloud-deployer-openshift.git
git add CHANGELOG.md
git commit -m "Add CHANGELOG [ci skip]" && git push origin HEAD:master

# Get latest (soon to be previous) release
previous_release_tag=$(curl -s \
    -u ${GITHUB_USERNAME}:${GITHUB_ACCESS_TOKEN} \
    https://api.github.com/repos/${GITHUB_USERNAME}/spring-cloud-deployer-openshift/releases/latest | \
        jq -r .tag_name)

# Create GitHub release
echo -e "\033[0;32mCreating GitHub release...\033[0m"
release_name="${TRAVIS_TAG:1}"
github_changelog_generator -t ${GITHUB_ACCESS_TOKEN} -o /tmp/CHANGELOG.md --since-tag ${previous_release_tag}
cat <(sed -e '$ d' /tmp/CHANGELOG.md) <(echo "Bintray artifacts: https://bintray.com/${GITHUB_USERNAME}/switchbit-public/spring-cloud-deployer-openshift/${release_name}") > /tmp/CHANGELOG.md.release
release_changelog=$(< /tmp/CHANGELOG.md.release)
jq -n \
    --arg tag_name "$TRAVIS_TAG" \
    --arg release_name "$release_name" \
    --arg release_changelog "$release_changelog" \
    '{
        "tag_name": $tag_name,
        "name": $release_name,
        "body": $release_changelog,
        "draft": false,
        "prerelease": false
    }' |
    curl -i \
        -u ${GITHUB_USERNAME}:${GITHUB_ACCESS_TOKEN} \
        -d@- \
        https://api.github.com/repos/${GITHUB_USERNAME}/spring-cloud-deployer-openshift/releases

# mvn deploy to Bintray
echo -e "\033[0;32mDeploying to Bintray...\033[0m"
./mvnw --settings .travis/settings.xml \
    org.codehaus.mojo:build-helper-maven-plugin:3.0.0:parse-version \
    versions:set -DnewVersion="${release_name}" \
    versions:commit
./mvnw --settings .travis/settings.xml -DskipTests=true -DperformRelease=true deploy

# Add documentation to donovanmuller.github.io
./mvnw -Pfull clean install -DskipTests
git clone git@github.com:donovanmuller/donovanmuller.github.io.git /tmp/donovanmuller.github.io
mkdir -p /tmp/donovanmuller.github.io/spring-cloud-dataflow-server-openshift/docs/${release_name}
unzip spring-cloud-dataflow-server-openshift-docs/target/spring-cloud-dataflow-server-openshift-docs-${release_name}.zip -d /tmp/donovanmuller.github.io/spring-cloud-dataflow-server-openshift/docs/${release_name}
git commit --all --message "Added spring-cloud-dataflow-server-openshift ${release_name} reference documentation" && git push origin master

# Build and push Docker image
./mvnw package docker:build -pl :spring-cloud-dataflow-server-openshift -DskipTests
docker tag donovanmuller/spring-cloud-dataflow-server-openshift:latest donovanmuller/spring-cloud-dataflow-server-openshift:${release_name}
docker login -u "$DOCKER_USERNAME" -p "$DOCKER_PASSWORD"
docker push donovanmuller/spring-cloud-dataflow-server-openshift:${release_name}

# Increment, commit and push the next development version
echo -e "\033[0;32mSetting next development version...\033[0m"
./mvnw --settings .travis/settings.xml \
    org.codehaus.mojo:build-helper-maven-plugin:3.0.0:parse-version \
    versions:set -DnewVersion=\${parsedVersion.majorVersion}.\${parsedVersion.minorVersion}.\${parsedVersion.nextIncrementalVersion}-SNAPSHOT \
    versions:commit
git add pom.xml
git commit -m "Set next development version [ci skip]" && git push origin HEAD:master      
