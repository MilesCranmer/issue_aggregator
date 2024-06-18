#!/bin/bash

post_type="issue"
issue_number=""
repo=""
user=""

usage() {
    echo "Usage: $0 -t <post_type> -n <issue_number> -r <repo> -u <user>"
    echo "  -t  Type of post (e.g., 'issue', 'discussion'). Defaults to 'issue'"
    echo "  -n  Issue number"
    echo "  -r  Repository."
    echo "  -u  User account that owns the repo."
    exit 1
}

# Parse command-line options
while getopts "t:n:r:u:" opt; do
    case $opt in
        t) post_type=$OPTARG ;;
        n) issue_number=$OPTARG ;;
        r) repo=$OPTARG ;;
        u) user=$OPTARG ;;
        ?) usage ;;
    esac
done

# Check if necessary arguments are provided
if [ -z "$post_type" ] || [ -z "$issue_number" ] || [ -z "$repo" ] || [ -z "$user" ]; then
    usage
fi

cmd=$(cat <<EOF
query(\$owner: String!, \$repo: String!, \$issueNumber: Int!) {
repository(owner: \$owner, name: \$repo) {
    $post_type(number: \$issueNumber) {
        number
        title
        body
        comments(first: 100) {
            nodes {
                author {
                    login
                }
                body
                createdAt
            }
            pageInfo {
                hasNextPage
                endCursor
            }
        }
    }
}
}
EOF
)

result=$(gh api graphql -F owner="$user" -F repo="$repo" -F "issueNumber=$issue_number" -f "query=$cmd")
exit_code=$?

if [ $exit_code -ne 0 ]; then
    echo "Error fetching $post_type $issue_number"
else
    filename="${post_type}${issue_number}.json"
    echo "Saving to $filename"
    echo "$result" > "$filename"
fi

# Usage:
# > ./download.sh -t "issue" -n 123 -r "PySR" -u "MilesCranmer"
