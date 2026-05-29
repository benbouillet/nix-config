{ pkgs }:

pkgs.writeShellScriptBin "github-commits" ''
  set -euo pipefail

  # Default values
  DAYS=7
  OUTPUT_FORMAT="text"
  ORG=""
  VERBOSE=false
  SORT_SPEC="datetime:desc"

  # Help message
  usage() {
    echo "Usage: github-commits [OPTIONS]"
    echo ""
    echo "Options:"
    echo "  -o, --org ORG        GitHub organization (required)"
    echo "  -d, --days DAYS      Number of days to look back (default: 7)"
    echo "  -j, --json           Output in JSON format"
    echo "  -s, --sort SPEC      Sort order in format field:direction (default: datetime:desc)"
    echo "                       Fields: datetime, repo"
    echo "                       Directions: asc, desc"
    echo "                       If direction omitted: datetime defaults to desc, repo defaults to asc"
    echo "  -v, --verbose        Enable verbose output"
    echo "  -h, --help           Show this help message"
    echo ""
    echo "Examples:"
    echo "  github-commits -o myorg"
    echo "  github-commits --org myorg --days 30"
    echo "  github-commits -o myorg -d 14 -j"
    echo "  github-commits -o myorg -s datetime:asc"
    echo "  github-commits --org myorg --sort repo:desc"
    echo "  github-commits -o myorg -s repo -v"
  }

  # Log function for verbose output
  log() {
    if [[ "''${VERBOSE}" == "true" ]]; then
      echo "$@" >&2
    fi
  }

  # Parse long options manually
  while [[ $# -gt 0 ]]; do
    case $1 in
      --org)
        ORG="$2"
        shift 2
        ;;
      --days)
        DAYS="$2"
        shift 2
        ;;
      --json)
        OUTPUT_FORMAT="json"
        shift
        ;;
      --sort)
        SORT_SPEC="$2"
        shift 2
        ;;
      --verbose)
        VERBOSE=true
        shift
        ;;
      --help)
        usage
        exit 0
        ;;
      --*)
        echo "Unknown option $1" >&2
        usage >&2
        exit 1
        ;;
      *)
        break
        ;;
    esac
  done

  # Parse short options with getopts
  while getopts "o:d:s:jvh" opt; do
    case $opt in
      o)
        ORG="$OPTARG"
        ;;
      d)
        DAYS="$OPTARG"
        ;;
      s)
        SORT_SPEC="$OPTARG"
        ;;
      j)
        OUTPUT_FORMAT="json"
        ;;
      v)
        VERBOSE=true
        ;;
      h)
        usage
        exit 0
        ;;
      \?)
        echo "Invalid option: -$OPTARG" >&2
        usage >&2
        exit 1
        ;;
      :)
        echo "Option -$OPTARG requires an argument." >&2
        usage >&2
        exit 1
        ;;
    esac
  done

  # Validate required arguments
  if [[ -z "''${ORG:-}" ]]; then
    echo "Error: --org/-o is required" >&2
    usage >&2
    exit 1
  fi

  # Parse and validate sort specification
  SORT_FIELD=""
  SORT_DIR=""
  
  # Split the sort spec on ':'
  IFS=':' read -r FIELD DIRECTION <<< "''${SORT_SPEC}"
  
  # Set defaults based on field
  if [[ -z "''${DIRECTION}" ]]; then
    if [[ "''${FIELD}" == "datetime" ]]; then
      DIRECTION="desc"
    elif [[ "''${FIELD}" == "repo" ]]; then
      DIRECTION="asc"
    else
      # Invalid field
      FIELD=""
    fi
  fi
  
  # Validate field
  if [[ "''${FIELD}" != "datetime" && "''${FIELD}" != "repo" ]]; then
    echo "Error: Invalid sort field ''${FIELD}'. Valid fields are: datetime, repo" >&2
    exit 1
  fi
  
  # Validate direction
  if [[ "''${DIRECTION}" != "asc" && "''${DIRECTION}" != "desc" ]]; then
    echo "Error: Invalid sort direction ''${DIRECTION}'. Valid directions are: asc, desc" >&2
    exit 1
  fi
  
  SORT_FIELD="''${FIELD}"
  SORT_DIR="''${DIRECTION}"
  
  # Log sort info for verbose mode
  if [[ "''${VERBOSE}" == "true" ]]; then
    log "Sorting by: ''${SORT_FIELD} (''${SORT_DIR})"
  fi

  # Check if gh is installed and authenticated
  if ! command -v gh >/dev/null 2>&1; then
    echo "Error: GitHub CLI (gh) is not installed" >&2
    exit 1
  fi

  if ! gh auth status >/dev/null 2>&1; then
    echo "Error: Not authenticated with GitHub CLI. Run 'gh auth login' first." >&2
    exit 1
  fi

  # Get the authenticated user's login and email
  read -r USER_LOGIN USER_EMAIL <<< $(gh api user | jq -r '[.login, .email] | @tsv')
  
  # Use login as the primary identifier for commits (works even when email is private)
  if [[ -z "''${USER_LOGIN}" ]]; then
    echo "Error: Could not retrieve user login from GitHub" >&2
    exit 1
  fi
  
  # Log user info for verbose mode
  if [[ "''${VERBOSE}" == "true" ]]; then
    if [[ "''${USER_EMAIL}" == "null" ]] || [[ -z "''${USER_EMAIL}" ]]; then
      log "User: ''${USER_LOGIN} (email is private)"
    else
      log "User: ''${USER_LOGIN} (''${USER_EMAIL})"
    fi
  fi

  # Create temporary files
  TEMP_REPOS=$(mktemp)
  TEMP_COMMITS=$(mktemp)

  # Cleanup function
  cleanup() {
    rm -f "''${TEMP_REPOS}" "''${TEMP_COMMITS}"
  }
  trap cleanup EXIT

  # Get all repositories for the organization
  log "Fetching repositories for organization: ''${ORG}"
  
  gh api --paginate "/orgs/''${ORG}/repos" | jq -r '.[].name' > "''${TEMP_REPOS}" 2>/dev/null || true
  
  # Count repositories
  REPO_COUNT=$(wc -l < "''${TEMP_REPOS}" | tr -d ' ')
  log "Found ''${REPO_COUNT} repositories"

  # Calculate the since date
  if date -u -d "''${DAYS} days ago" "+%Y-%m-%dT%H:%M:%SZ" >/dev/null 2>&1; then
    SINCE_DATE=$(date -u -d "''${DAYS} days ago" "+%Y-%m-%dT%H:%M:%SZ")
  elif date -u -v-"''${DAYS}"d "+%Y-%m-%dT%H:%M:%SZ" >/dev/null 2>&1; then
    SINCE_DATE=$(date -u -v-"''${DAYS}"d "+%Y-%m-%dT%H:%M:%SZ")
  else
    echo "Error: Unable to calculate date" >&2
    exit 1
  fi
  
  # Process each repository
  log "Looking back ''${DAYS} days (since ''${SINCE_DATE})"
  
  while IFS= read -r REPO; do
    if [[ -n "''${REPO}" ]]; then
      log "Checking ''${ORG}/''${REPO}..."
      
      # Get commits for this repository and append to temp file
      COMMITS_TEMP=$(mktemp)
      gh api "repos/''${ORG}/''${REPO}/commits?author=''${USER_LOGIN}&since=''${SINCE_DATE}" 2>/dev/null > "''${COMMITS_TEMP}" || true
      
      # Count commits for this repo
      COMMIT_COUNT=$(jq -r 'length' "''${COMMITS_TEMP}")
      if [[ "''${COMMIT_COUNT}" -gt 0 ]]; then
        log "Found ''${COMMIT_COUNT} commits in ''${REPO}"
      fi
      
      # Process commits
      jq -c --arg repo "''${REPO}" '.[] | {datetime: .commit.author.date, sha: .sha, repo: $repo, message: (.commit.message | gsub("[\n\r\t]"; " ") | .[0:100])}' "''${COMMITS_TEMP}" >> "''${TEMP_COMMITS}" || true
      
      # Clean up temp file
      rm -f "''${COMMITS_TEMP}"
    fi
  done < "''${TEMP_REPOS}"

  # Count total commits
  TOTAL_COMMITS=$(wc -l < "''${TEMP_COMMITS}" | tr -d ' ')
  log "Total commits found: ''${TOTAL_COMMITS}"
  
  # Output results
  if [[ "''${OUTPUT_FORMAT}" == "json" ]]; then
    # Convert to JSON array
    if [[ -s "''${TEMP_COMMITS}" ]]; then
      # Add org prefix to repo names and convert to proper JSON array
      if [[ "''${SORT_FIELD}" == "datetime" ]]; then
        if [[ "''${SORT_DIR}" == "asc" ]]; then
          jq -s --arg org "''${ORG}" 'map({datetime: .datetime, sha: .sha, repo: ($org + "/" + .repo), message: .message}) | sort_by(.datetime)' "''${TEMP_COMMITS}"
        else
          jq -s --arg org "''${ORG}" 'map({datetime: .datetime, sha: .sha, repo: ($org + "/" + .repo), message: .message}) | sort_by(.datetime) | reverse' "''${TEMP_COMMITS}"
        fi
      else  # repo sorting
        if [[ "''${SORT_DIR}" == "asc" ]]; then
          jq -s --arg org "''${ORG}" 'map({datetime: .datetime, sha: .sha, repo: ($org + "/" + .repo), message: .message}) | sort_by(.repo, .datetime)' "''${TEMP_COMMITS}"
        else
          jq -s --arg org "''${ORG}" 'map({datetime: .datetime, sha: .sha, repo: ($org + "/" + .repo), message: .message}) | sort_by(.repo, .datetime) | reverse' "''${TEMP_COMMITS}"
        fi
      fi
    else
      echo "[]"
    fi
  else
    # Output in text format
    if [[ -s "''${TEMP_COMMITS}" ]]; then
      if [[ "''${SORT_FIELD}" == "datetime" ]]; then
        if [[ "''${SORT_DIR}" == "asc" ]]; then
          jq -rs --arg org "''${ORG}" 'sort_by(.datetime) | .[] | "\(.datetime) | \(.sha[0:7]) | \($org)/\(.repo) | \(.message)"' "''${TEMP_COMMITS}"
        else
          jq -rs --arg org "''${ORG}" 'sort_by(.datetime) | reverse | .[] | "\(.datetime) | \(.sha[0:7]) | \($org)/\(.repo) | \(.message)"' "''${TEMP_COMMITS}"
        fi
      else  # repo sorting
        if [[ "''${SORT_DIR}" == "asc" ]]; then
          jq -rs --arg org "''${ORG}" 'sort_by(.repo, .datetime) | .[] | "\(.datetime) | \(.sha[0:7]) | \($org)/\(.repo) | \(.message)"' "''${TEMP_COMMITS}"
        else
          jq -rs --arg org "''${ORG}" 'sort_by(.repo, .datetime) | reverse | .[] | "\(.datetime) | \(.sha[0:7]) | \($org)/\(.repo) | \(.message)"' "''${TEMP_COMMITS}"
        fi
      fi
    fi
  fi
''