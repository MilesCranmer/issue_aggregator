def get_issue [
    -t: string,
    -n: int,
    -r: string,
    -u: string
] {
    let post_type = $t
    let issue_number = $n
    let repo = $r
    let user = $u

    let cmd = $"
        query\($owner: String!, $repo: String!, $issueNumber: Int!\) {
            repository\(owner: $owner, name: $repo\) {
                ($post_type)\(number: $issueNumber\) {
                    number
                    title
                    body
                    comments\(first: 100\) {
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
    "
    let result = gh api graphql -F $"owner=($user)" -F $"repo=($repo)" -F $"issueNumber=($issue_number)" -f $"query=($cmd)" | complete
    let exit_code = $result.exit_code
    let contents = $result.stdout | from json
    if ($exit_code != 0) {
        echo $"Error fetching ($post_type) ($issue_number)"
    } else {
        let filename = $"($post_type)($issue_number).json"
        echo $"Saving to ($filename)"
        $contents | save -f $filename
    }
}

# Usage:
# > source download.nu
# > get_issue -t "issue" -n 123 -r "PySR" -u "MilesCranmer"
