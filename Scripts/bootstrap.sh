#!/bin/bash

# Copyright (c) 2023 Jason Barrie Morley
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.

set -e
set -o pipefail
set -x
set -u

SCRIPTS_DIRECTORY="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"

ROOT_DIRECTORY="${SCRIPTS_DIRECTORY}/.."
BUILD_DIRECTORY="${ROOT_DIRECTORY}/build"
TEMPORARY_DIRECTORY="${ROOT_DIRECTORY}/temp"

KEYCHAIN_PATH="${TEMPORARY_DIRECTORY}/temporary.keychain"
MACOS_ARCHIVE_PATH="${BUILD_DIRECTORY}/Bookmarks-macOS.xcarchive"
FASTLANE_ENV_PATH="${ROOT_DIRECTORY}/fastlane/.env"

CHANGES_DIRECTORY="${SCRIPTS_DIRECTORY}/changes"
BUILD_TOOLS_DIRECTORY="${SCRIPTS_DIRECTORY}/build-tools"

RELEASE_SCRIPT_PATH="${SCRIPTS_DIRECTORY}/release.sh"

PATH=$PATH:$CHANGES_DIRECTORY
PATH=$PATH:$BUILD_TOOLS_DIRECTORY

MACOS_XCODE_PATH=${MACOS_XCODE_PATH:-/Applications/Xcode.app}

source "${SCRIPTS_DIRECTORY}/environment.sh"

# Check that the GitHub command is available on the path.
which gh || (echo "GitHub cli (gh) not available on the path." && exit 1)

# Process the command line arguments.
# POSITIONAL=()
# RELEASE=${RELEASE:-false}
# while [[ $# -gt 0 ]]
# do
#     key="$1"
#     case $key in
#         -r|--release)
#         RELEASE=true
#         shift
#         ;;
#         *)
#         POSITIONAL+=("$1")
#         shift
#         ;;
#     esac
# done

# Generate a random string to secure the local keychain.
export TEMPORARY_KEYCHAIN_PASSWORD=`openssl rand -base64 14`

# Source the Fastlane .env file if it exists to make local development easier.
if [ -f "$FASTLANE_ENV_PATH" ] ; then
    echo "Sourcing .env..."
    source "$FASTLANE_ENV_PATH"
fi

cd "$ROOT_DIRECTORY"

# Install our dependencies.
"${SCRIPTS_DIRECTORY}/install-dependencies.sh"

# Build and test.
# sudo xcode-select --switch "$MACOS_XCODE_PATH"
# make clean
# make test
# make release

# Clean up the build directory.
if [ -d "$BUILD_DIRECTORY" ] ; then
    rm -r "$BUILD_DIRECTORY"
fi
mkdir -p "$BUILD_DIRECTORY"

# Create the a new keychain.
if [ -d "$TEMPORARY_DIRECTORY" ] ; then
    rm -rf "$TEMPORARY_DIRECTORY"
fi
mkdir -p "$TEMPORARY_DIRECTORY"
echo "$TEMPORARY_KEYCHAIN_PASSWORD" | build-tools create-keychain "$KEYCHAIN_PATH" --password

function cleanup {

    # Cleanup the temporary files and keychain.
    cd "$ROOT_DIRECTORY"
    build-tools delete-keychain "$KEYCHAIN_PATH"
    rm -rf "$TEMPORARY_DIRECTORY"
}

trap cleanup EXIT

COMMAND=$0; shift

echo "Running \'$COMMAND\' with arguments '$@'..."

# Determine the version and build number.
# VERSION_NUMBER=`changes version`
# BUILD_NUMBER=`build-tools generate-build-number`

# Import the certificates into our dedicated keychain.
# echo "DEVELOPER_ID_APPLICATION_CERTIFICATE_PASSWORD" | build-tools import-base64-certificate --password "$KEYCHAIN_PATH" "DEVELOPER_ID_APPLICATION_CERTIFICATE_BASE64"
#
# exit 0

# Install the provisioning profiles.
# build-tools install-provisioning-profile "profiles/Bookmarks_App_Store_Profile.mobileprovision"
# build-tools install-provisioning-profile "profiles/Bookmarks_Share_Extension_App_Store_Profile.mobileprovision"
# build-tools install-provisioning-profile "profiles/Bookmarks_Mac_App_Store_Profile.provisionprofile"
# build-tools install-provisioning-profile "profiles/Bookmarks_for_Safari_Mac_App_Store_Profile.provisionprofile"

# TODO: Sign the binary?

# Archive the build directory.
# ZIP_BASENAME="build-${VERSION_NUMBER}-${BUILD_NUMBER}.zip"
# ZIP_PATH="${BUILD_DIRECTORY}/${ZIP_BASENAME}"
# pushd "${BUILD_DIRECTORY}"
# zip -r "${ZIP_BASENAME}" .
# popd
#
# if $RELEASE ; then
#
#     IPA_PATH="${BUILD_DIRECTORY}/Bookmarks.ipa"
#     PKG_PATH="${BUILD_DIRECTORY}/Bookmarks.pkg"
#
#     changes \
#         release \
#         --skip-if-empty \
#         --pre-release \
#         --push \
#         --exec "${RELEASE_SCRIPT_PATH}" \
#         "${IPA_PATH}" "${PKG_PATH}" "${ZIP_PATH}"
#     unlink "$API_KEY_PATH"
#
# fi
