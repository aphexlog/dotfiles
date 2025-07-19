package utils

import (
	"fmt"
	"os"
	"os/exec"
	"path/filepath"
	"strings"
	"time"

	"github.com/fatih/color"
)

var (
	Red    = color.New(color.FgRed)
	Green  = color.New(color.FgGreen)
	Yellow = color.New(color.FgYellow)
	Blue   = color.New(color.FgBlue)
	Purple = color.New(color.FgMagenta)
	Cyan   = color.New(color.FgCyan)
)

// EnsureDir creates a directory if it doesn't exist
func EnsureDir(path string) error {
	if _, err := os.Stat(path); os.IsNotExist(err) {
		return os.MkdirAll(path, 0755)
	}
	return nil
}

// ListProjects returns a list of directories in the given path
func ListProjects(path string) ([]string, error) {
	var projects []string
	
	if _, err := os.Stat(path); os.IsNotExist(err) {
		return projects, nil
	}
	
	entries, err := os.ReadDir(path)
	if err != nil {
		return nil, err
	}
	
	for _, entry := range entries {
		if entry.IsDir() && !strings.HasPrefix(entry.Name(), ".") {
			projects = append(projects, entry.Name())
		}
	}
	
	return projects, nil
}

// ProjectExists checks if a project exists in the given directory
func ProjectExists(dir, project string) bool {
	path := filepath.Join(dir, project)
	if stat, err := os.Stat(path); err == nil && stat.IsDir() {
		return true
	}
	return false
}

// CreateProject creates a new project with basic structure
func CreateProject(path, name string, isWork bool) error {
	projectPath := filepath.Join(path, name)
	
	if err := EnsureDir(projectPath); err != nil {
		return err
	}
	
	// Create basic directory structure
	dirs := []string{"src", "docs", "tests"}
	if isWork {
		dirs = append(dirs, "config")
	}
	
	for _, dir := range dirs {
		if err := EnsureDir(filepath.Join(projectPath, dir)); err != nil {
			return err
		}
	}
	
	// Create README
	readmePath := filepath.Join(projectPath, "README.md")
	projectType := "Personal"
	if isWork {
		projectType = "Corporate"
	}
	
	content := fmt.Sprintf("# %s\n\n%s project created on %s\n", 
		name, projectType, time.Now().Format("2006-01-02"))
	
	if err := os.WriteFile(readmePath, []byte(content), 0644); err != nil {
		return err
	}
	
	// Initialize git if available
	if _, err := exec.LookPath("git"); err == nil {
		cmd := exec.Command("git", "init")
		cmd.Dir = projectPath
		cmd.Run()
	}
	
	return nil
}

// OpenInEditor opens the project in the default editor
func OpenInEditor(path string) error {
	editor := os.Getenv("EDITOR")
	if editor == "" {
		editor = "code" // Default to VS Code
	}
	
	cmd := exec.Command(editor, path)
	return cmd.Start()
}

// ChangeDirectory prints the command to change directory
func ChangeDirectory(path string) {
	fmt.Printf("cd %s\n", path)
}

// PrintProjectList prints a formatted list of projects
func PrintProjectList(title, emoji string, projects []string) {
	Purple.Printf("\n%s %s\n", emoji, title)
	if len(projects) == 0 {
		Yellow.Println("  (empty)")
		return
	}
	
	for _, project := range projects {
		fmt.Printf("  %s %s\n", getProjectEmoji(title), project)
	}
}

func getProjectEmoji(title string) string {
	switch {
	case strings.Contains(title, "FORGE"):
		return "🔨"
	case strings.Contains(title, "CORP"):
		return "💼"
	case strings.Contains(title, "LABS"):
		return "⚗️"
	case strings.Contains(title, "ARCHIVE"):
		return "📜"
	default:
		return "📁"
	}
}
