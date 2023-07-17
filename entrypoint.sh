#!/usr/bin/env bash
# Using /usr/bin/env bash is probably unnecessary but doesn't hurt.
# See https://tldp.org/LDP/abs/html/sha-bang.html#AEN269

VERSION="${1:?Must supply the version. Exiting with status 1.}"

# Taken from https://github.com/actions/checkout/issues/760
git config --global --add safe.directory "$GITHUB_WORKSPACE"
git config --global --add safe.directory /github/workspace

if [ $(git tag --list "$VERSION") ]
then
    echo "Tag $VERSION already exists. Exiting"
    exit 0
fi

echo "Tagging the repo with ${VERSION} to commit ${GITHUB_SHA}"

curl --silent --show-error --fail-with-body -X POST https://api.github.com/repos/$GITHUB_REPOSITORY/git/refs \
  -H "Accept: application/vnd.github.v3+json" \
  -H "Authorization: token $GITHUB_TOKEN" \
  -d @- << EOF
{
  "ref": "refs/tags/${VERSION}",
  "sha": "${GITHUB_SHA}"
}
EOF
