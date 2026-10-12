#!/usr/bin/env bash
# ==============================================================================
# Vivid Studio • GitHub Pages Deployment Script
# Syncs changes from `admin/` on `main` directly to the `gh-pages` branch.
# ==============================================================================

set -e

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$REPO_DIR"

echo "🚀 Deploying Vivid Studio Web Uploader to gh-pages..."

# Ensure working directory is clean or changes are committed
if ! git diff-index --quiet HEAD --; then
  echo "⚠️ Working directory has uncommitted changes. Please commit them first on main:"
  echo "   git add admin/ && git commit -m 'Update admin uploader'"
  exit 1
fi

# Split admin folder into gh-pages branch and force-push
echo "📦 Splitting admin/ subtree to gh-pages branch..."
git subtree split --prefix admin -b gh-pages-temp
git push origin gh-pages-temp:gh-pages --force
git branch -D gh-pages-temp

echo "✅ Successfully deployed to GitHub Pages!"
echo "🌐 URL: https://ishara-madu.github.io/vivid-ai-wallpapers/"
