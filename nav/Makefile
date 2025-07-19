.PHONY: build install clean test help

# Build variables
BINARY_NAME=nav
BUILD_DIR=bin
INSTALL_DIR=$(HOME)/.local/bin

# Go build flags
LDFLAGS=-ldflags "-s -w"
BUILD_FLAGS=-trimpath $(LDFLAGS)

help: ## Show this help message
	@echo "🚀 Nav CLI Build Commands"
	@echo "========================"
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "  \033[36m%-15s\033[0m %s\n", $$1, $$2}'

build: ## Build the nav CLI
	@echo "🔨 Building nav CLI..."
	@mkdir -p $(BUILD_DIR)
	@go build $(BUILD_FLAGS) -o $(BUILD_DIR)/$(BINARY_NAME) ./cmd/nav
	@echo "✅ Built $(BUILD_DIR)/$(BINARY_NAME)"

install: build ## Build and install nav CLI to ~/.local/bin
	@echo "📦 Installing nav CLI..."
	@mkdir -p $(INSTALL_DIR)
	@cp $(BUILD_DIR)/$(BINARY_NAME) $(INSTALL_DIR)/
	@chmod +x $(INSTALL_DIR)/$(BINARY_NAME)
	@echo "✅ Installed to $(INSTALL_DIR)/$(BINARY_NAME)"
	@echo "💡 Make sure $(INSTALL_DIR) is in your PATH"

uninstall: ## Remove nav CLI from ~/.local/bin
	@echo "🗑️  Uninstalling nav CLI..."
	@rm -f $(INSTALL_DIR)/$(BINARY_NAME)
	@echo "✅ Uninstalled nav CLI"

clean: ## Clean build artifacts
	@echo "🧹 Cleaning build artifacts..."
	@rm -rf $(BUILD_DIR)
	@echo "✅ Cleaned build directory"

test: ## Run tests
	@echo "🧪 Running tests..."
	@go test -v ./...

deps: ## Download and tidy dependencies
	@echo "📦 Managing dependencies..."
	@go mod download
	@go mod tidy
	@echo "✅ Dependencies updated"

dev: ## Build and run in development mode
	@echo "🚀 Running in development mode..."
	@go run ./cmd/nav

# Cross-compilation targets
build-all: ## Build for multiple platforms
	@echo "🔨 Building for multiple platforms..."
	@mkdir -p $(BUILD_DIR)
	@GOOS=darwin GOARCH=amd64 go build $(BUILD_FLAGS) -o $(BUILD_DIR)/$(BINARY_NAME)-darwin-amd64 ./cmd/nav
	@GOOS=darwin GOARCH=arm64 go build $(BUILD_FLAGS) -o $(BUILD_DIR)/$(BINARY_NAME)-darwin-arm64 ./cmd/nav
	@GOOS=linux GOARCH=amd64 go build $(BUILD_FLAGS) -o $(BUILD_DIR)/$(BINARY_NAME)-linux-amd64 ./cmd/nav
	@GOOS=windows GOARCH=amd64 go build $(BUILD_FLAGS) -o $(BUILD_DIR)/$(BINARY_NAME)-windows-amd64.exe ./cmd/nav
	@echo "✅ Built for multiple platforms in $(BUILD_DIR)/"
