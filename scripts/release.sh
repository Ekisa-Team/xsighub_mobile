#!/bin/bash

# Prompt for release type
read -p "Enter release type (major, minor, patch): " release_type

# Validate release type
case $release_type in
major | minor | patch) ;;
*)
    echo "Invalid release type"
    exit 1
    ;;
esac

# Prompt for release scope
read -p "Do you want to specify a release scope? (y/n): " prompt_scope

# Convert input to lowercase
prompt_scope=$(echo "$prompt_scope" | tr '[:upper:]' '[:lower:]')

# Validate release scope
case $prompt_scope in
y | yes)
    read -p "Enter release scope (stable | beta | alpha): " release_scope

    # Convert input to lowercase
    release_scope=$(echo "$release_scope" | tr '[:upper:]' '[:lower:]')

    # Validate release scope input
    case $release_scope in
    stable | beta | alpha) ;;
    *)
        echo "Invalid release scope"
        exit 1
        ;;
    esac
    ;;
n | no)
    release_scope=""
    ;;
*)
    echo "Invalid choice"
    exit 1
    ;;
esac

# Read current version from pubspec.yaml
version=$(grep 'version:' pubspec.yaml | awk '{print $2}')

# Determine new version
case $release_type in
major)
    new_version=$(echo $version | awk -F. -v OFS=. '{$1++; $2=0; $3=0} {print $0}')
    ;;
minor)
    new_version=$(echo $version | awk -F. -v OFS=. '{$2++; $3=0} {print $0}')
    ;;
patch)
    new_version=$(echo $version | awk -F. -v OFS=. '{$3++} {print $0}')
    ;;
esac

# Append release scope (if any) to new version
if [ -n "$release_scope" ]; then
    new_version="${new_version}-${release_scope}"
fi

new_version_prefixed="v${new_version}"

# Create git tag with new version
git tag -a "v$new_version_prefixed" -m "Release $new_version_prefixed"
echo "Created git tag $new_version_prefixed"

# Update pubspec.yaml with new version
sed -i "s/version: $version/version: $new_version/" pubspec.yaml
echo "Updated pubspec.yaml with version $new_version"

# Commit changes to pubspec.yaml
git commit -m "Bump version to $new_version" pubspec.yaml
echo "Commited changes to pubspec.yaml"

# Push pubspec.yaml changes
git push origin HEAD
echo "Pushed pubspec.yaml changes"

# Push git tag
git push origin $new_version_prefixed
echo "Pushed git tag $new_version_prefixed. Check https://github.com/Ekisa-Team/xsighub_mobile/actions to follow up the active workflow."
