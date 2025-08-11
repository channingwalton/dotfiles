#!/opt/homebrew/bin/bash

# Modified Tests Runner
# Finds and runs only the git-modified test files in a Scala project

set -e # Exit on any error

# Configuration
# Use first argument as working directory, or PWD if not provided
PROJECT_ROOT="${1:-${PWD}}"
VERBOSE=false

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Usage function
usage() {
  echo "Usage: $0 [WORKING_DIR] [OPTIONS]"
  echo "Find and run git-modified Scala test files"
  echo ""
  echo "Arguments:"
  echo "  WORKING_DIR          Working directory (optional, defaults to current directory)"
  echo ""
  echo "Options:"
  echo "  -v, --verbose        Enable verbose output"
  echo "  -d, --dry-run        Show what would be run without executing"
  echo "  -h, --help           Show this help message"
  echo ""
  echo "Examples:"
  echo "  $0                               # Run git-modified tests in current directory"
  echo "  $0 /path/to/project              # Run git-modified tests in specified directory"
  echo "  $0 /path/to/project -v --dry-run # Show git-modified tests without running"
}

# Logging functions
log_info() {
  echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
  echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warning() {
  echo -e "${YELLOW}[WARNING]${NC} $1"
}

log_error() {
  echo -e "${RED}[ERROR]${NC} $1"
}

log_verbose() {
  if [ "$VERBOSE" = true ]; then
    echo -e "${BLUE}[VERBOSE]${NC} $1"
  fi
}

# Find test directories
find_test_directories() {
  find "$PROJECT_ROOT" -type d -name "test" | grep -E "src/test$" | while read -r test_dir; do
    # Ensure it looks like a test directory (contains scala files or subdirs)
    if [ -n "$(find "$test_dir" -name "*.scala" -type f | head -1)" ]; then
      echo "$test_dir"
    fi
  done
}

# Check if file is a Scala test file
is_scala_test_file() {
  local file="$1"
  local basename=$(basename "$file")

  # Check if it's a Scala file and matches test patterns
  if [[ "$file" == *.scala ]] && [[ "$basename" =~ (Test|Spec)\.scala$ || "$basename" =~ .*(Test|Spec).* ]]; then
    return 0
  fi
  return 1
}

# Convert file path to test class name
file_to_class_name() {
  local test_dir="$1"
  local file_path="$2"

  # Get relative path from test directory (macOS compatible)
  local rel_path="${file_path#$test_dir/}"
  
  # Remove scala/ prefix if present
  rel_path="${rel_path#scala/}"

  # Remove .scala extension and convert path separators to dots
  local class_name="${rel_path%.scala}"
  class_name="${class_name//\//.}"

  echo "$class_name"
}


# Find modified tests using git
find_modified_tests() {
  local test_files=()

  # Check if we're in a git repository
  if ! git rev-parse --git-dir >/dev/null 2>&1; then
    log_error "Not in a git repository. Use -t option instead." >&2
    exit 1
  fi

  # Get modified files from git (try multiple sources)
  local git_files
  git_files=$(git diff --name-only HEAD~1 HEAD 2>/dev/null || echo "")
  
  # If no committed changes, check staged changes
  if [ -z "$git_files" ]; then
    git_files=$(git diff --name-only --cached 2>/dev/null || echo "")
  fi
  
  # If still no changes, check unstaged changes
  if [ -z "$git_files" ]; then
    log_warning "No committed or staged files found. Checking unstaged changes..." >&2
    git_files=$(git diff --name-only 2>/dev/null || echo "")
  fi
  
  # Also check unstaged changes in addition to any committed/staged changes
  local unstaged_files
  unstaged_files=$(git diff --name-only 2>/dev/null || echo "")
  if [ -n "$unstaged_files" ]; then
    git_files=$(printf "%s\n%s" "$git_files" "$unstaged_files" | sort -u)
  fi

  # Find test directories for reference
  local test_dirs
  test_dirs=$(find_test_directories)

  echo "$git_files" | while read -r file; do
    if [ -n "$file" ] && [ -f "$file" ] && is_scala_test_file "$file"; then
      # Convert relative path to absolute path
      local abs_file="$PROJECT_ROOT/$file"
      
      # Check if file is under a test directory
      echo "$test_dirs" | while read -r test_dir; do
        if [[ "$abs_file" == "$test_dir"/* ]]; then
          class_name=$(file_to_class_name "$test_dir" "$abs_file")
          echo "$class_name"
          log_verbose "Found git-modified test: $file -> $class_name" >&2
          break
        fi
      done
    fi
  done
}

# Run tests with sbt
run_tests() {
  local test_classes=("$@")

  if [ ${#test_classes[@]} -eq 0 ]; then
    log_warning "No modified tests found."
    return 0
  fi

  log_info "Found ${#test_classes[@]} modified test(s):"
  printf '  - %s\n' "${test_classes[@]}"

  if [ "$DRY_RUN" = true ]; then
    log_info "DRY RUN: Would run the following sbt command:"
    echo "sbt \"testOnly ${test_classes[*]}\""
    return 0
  fi

  log_info "Running tests with sbt..."
  local sbt_command="testOnly ${test_classes[*]}"

  log_verbose "Executing: sbt \"$sbt_command\""

  if sbt "$sbt_command"; then
    log_success "All tests completed successfully!"
  else
    log_error "Tests failed!"
    exit 1
  fi
}

# Parse command line arguments
parse_args() {
  DRY_RUN=false
  local args=("$@")
  
  # Skip first argument if it looks like a directory path (not an option)
  if [[ $# -gt 0 && "$1" != -* ]]; then
    shift
  fi

  while [[ $# -gt 0 ]]; do
    case $1 in
    -v | --verbose)
      VERBOSE=true
      shift
      ;;
    -d | --dry-run)
      DRY_RUN=true
      shift
      ;;
    -h | --help)
      usage
      exit 0
      ;;
    *)
      log_error "Unknown option: $1"
      usage
      exit 1
      ;;
    esac
  done
}

# Main function
main() {
  parse_args "$@"

  # Validate working directory
  if [ ! -d "$PROJECT_ROOT" ]; then
    log_error "Directory does not exist: $PROJECT_ROOT"
    exit 1
  fi

  log_info "Modified Tests Runner - Scanning project: $PROJECT_ROOT"

  # Find modified tests
  log_info "Looking for tests modified since last commit..."
  local test_classes=()
  while IFS= read -r class_name; do
    if [ -n "$class_name" ]; then
      test_classes+=("$class_name")
    fi
  done < <(find_modified_tests 2>/dev/null | sort -u)

  # Run the tests
  run_tests "${test_classes[@]}"
}

# Run main function with all arguments
main "$@"
