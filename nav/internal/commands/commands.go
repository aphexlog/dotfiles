package commands

import (
	"fmt"
	"os"
	"path/filepath"
	"strings"

	"nav/internal/utils"

	"github.com/spf13/cobra"
)

var (
	codeRoot   string
	forgeDir   string
	corpDir    string
	labDir     string
	archiveDir string
)

func init() {
	homeDir, _ := os.UserHomeDir()
	codeRoot = filepath.Join(homeDir, "Code")
	forgeDir = filepath.Join(codeRoot, "forge")
	corpDir = filepath.Join(codeRoot, "corp")
	labDir = filepath.Join(codeRoot, "labs")
	archiveDir = filepath.Join(codeRoot, "archive")
}

// InitCmd initializes the workspace
var InitCmd = &cobra.Command{
	Use:   "init",
	Short: "Initialize coding workspace directories",
	Run: func(cmd *cobra.Command, args []string) {
		utils.Cyan.Println("🔧 Initializing coding workspace...")
		
		dirs := map[string]string{
			"forge":   forgeDir,
			"corp":    corpDir,
			"labs":    labDir,
			"archive": archiveDir,
		}
		
		for name, path := range dirs {
			if err := utils.EnsureDir(path); err != nil {
				utils.Red.Printf("❌ Failed to create %s: %v\n", name, err)
			} else {
				if _, err := os.Stat(path); err == nil {
					utils.Green.Printf("✅ Created: %s\n", path)
				}
			}
		}
		
		utils.Purple.Println("🎉 Workspace ready!")
	},
}

// ForgeCmd handles forge navigation and project creation
var ForgeCmd = &cobra.Command{
	Use:   "forge [project]",
	Short: "Navigate to forge (personal projects)",
	Args:  cobra.MaximumNArgs(1),
	Run: func(cmd *cobra.Command, args []string) {
		if len(args) == 0 {
			utils.ChangeDirectory(forgeDir)
			return
		}
		
		project := args[0]
		projectPath := filepath.Join(forgeDir, project)
		
		if utils.ProjectExists(forgeDir, project) {
			utils.ChangeDirectory(projectPath)
		} else {
			utils.Red.Printf("❌ Project '%s' not found in forge\n", project)
			showAvailableProjects(forgeDir, "forge")
		}
	},
}

// CorpCmd handles corp navigation and project creation
var CorpCmd = &cobra.Command{
	Use:   "corp [project]",
	Short: "Navigate to corp (work projects)",
	Args:  cobra.MaximumNArgs(1),
	Run: func(cmd *cobra.Command, args []string) {
		if len(args) == 0 {
			utils.ChangeDirectory(corpDir)
			return
		}
		
		project := args[0]
		projectPath := filepath.Join(corpDir, project)
		
		if utils.ProjectExists(corpDir, project) {
			utils.ChangeDirectory(projectPath)
		} else {
			utils.Red.Printf("❌ Project '%s' not found in corp\n", project)
			showAvailableProjects(corpDir, "corp")
		}
	},
}

// LabCmd handles lab navigation
var LabCmd = &cobra.Command{
	Use:   "lab [project]",
	Short: "Navigate to labs (experiments)",
	Args:  cobra.MaximumNArgs(1),
	Run: func(cmd *cobra.Command, args []string) {
		if len(args) == 0 {
			utils.ChangeDirectory(labDir)
			return
		}
		
		project := args[0]
		projectPath := filepath.Join(labDir, project)
		
		if utils.ProjectExists(labDir, project) {
			utils.ChangeDirectory(projectPath)
		} else {
			utils.Red.Printf("❌ Experiment '%s' not found in labs\n", project)
			showAvailableProjects(labDir, "labs")
		}
	},
}

// ArchiveCmd handles archive navigation
var ArchiveCmd = &cobra.Command{
	Use:   "archive [project]",
	Short: "Navigate to archive (old projects)",
	Args:  cobra.MaximumNArgs(1),
	Run: func(cmd *cobra.Command, args []string) {
		if len(args) == 0 {
			utils.ChangeDirectory(archiveDir)
			return
		}
		
		project := args[0]
		projectPath := filepath.Join(archiveDir, project)
		
		if utils.ProjectExists(archiveDir, project) {
			utils.ChangeDirectory(projectPath)
		} else {
			utils.Red.Printf("❌ Project '%s' not found in archive\n", project)
			showAvailableProjects(archiveDir, "archive")
		}
	},
}

// NewCmd creates new projects
var NewCmd = &cobra.Command{
	Use:   "new",
	Short: "Create new projects",
}

var NewForgeCmd = &cobra.Command{
	Use:   "forge <name>",
	Short: "Create new personal project",
	Args:  cobra.ExactArgs(1),
	Run: func(cmd *cobra.Command, args []string) {
		name := args[0]
		projectPath := filepath.Join(forgeDir, name)
		
		if utils.ProjectExists(forgeDir, name) {
			utils.Yellow.Printf("⚠️  Project '%s' already exists\n", name)
			utils.ChangeDirectory(projectPath)
			return
		}
		
		if err := utils.CreateProject(forgeDir, name, false); err != nil {
			utils.Red.Printf("❌ Failed to create project: %v\n", err)
			return
		}
		
		utils.Green.Printf("🚀 Created new forge project: %s\n", name)
		utils.Cyan.Printf("📍 Location: %s\n", projectPath)
		utils.ChangeDirectory(projectPath)
	},
}

var NewCorpCmd = &cobra.Command{
	Use:   "corp <name>",
	Short: "Create new work project",
	Args:  cobra.ExactArgs(1),
	Run: func(cmd *cobra.Command, args []string) {
		name := args[0]
		projectPath := filepath.Join(corpDir, name)
		
		if utils.ProjectExists(corpDir, name) {
			utils.Yellow.Printf("⚠️  Project '%s' already exists\n", name)
			utils.ChangeDirectory(projectPath)
			return
		}
		
		if err := utils.CreateProject(corpDir, name, true); err != nil {
			utils.Red.Printf("❌ Failed to create project: %v\n", err)
			return
		}
		
		utils.Green.Printf("💼 Created new corp project: %s\n", name)
		utils.Cyan.Printf("📍 Location: %s\n", projectPath)
		utils.ChangeDirectory(projectPath)
	},
}

// ListCmd lists all projects
var ListCmd = &cobra.Command{
	Use:   "list",
	Short: "List all projects",
	Aliases: []string{"ls", "projects"},
	Run: func(cmd *cobra.Command, args []string) {
		forgeProjects, _ := utils.ListProjects(forgeDir)
		corpProjects, _ := utils.ListProjects(corpDir)
		labProjects, _ := utils.ListProjects(labDir)
		archiveProjects, _ := utils.ListProjects(archiveDir)
		
		utils.PrintProjectList("🏗️  FORGE (Personal Projects)", "🔨", forgeProjects)
		utils.PrintProjectList("🏢 CORP (Work Projects)", "💼", corpProjects)
		utils.PrintProjectList("🧪 LABS (Experiments)", "⚗️", labProjects)
		utils.PrintProjectList("📦 ARCHIVE (Old Projects)", "📜", archiveProjects)
	},
}

// FindCmd searches for projects
var FindCmd = &cobra.Command{
	Use:   "find <term>",
	Short: "Search for projects",
	Args:  cobra.ExactArgs(1),
	Run: func(cmd *cobra.Command, args []string) {
		term := strings.ToLower(args[0])
		utils.Cyan.Printf("🔍 Searching for projects matching '%s'...\n", term)
		
		dirs := map[string]string{
			"forge":   forgeDir,
			"corp":    corpDir,
			"labs":    labDir,
			"archive": archiveDir,
		}
		
		found := false
		for dirName, dirPath := range dirs {
			projects, err := utils.ListProjects(dirPath)
			if err != nil {
				continue
			}
			
			for _, project := range projects {
				if strings.Contains(strings.ToLower(project), term) {
					utils.Green.Printf("📁 %s/%s\n", dirName, project)
					found = true
				}
			}
		}
		
		if !found {
			utils.Yellow.Println("No projects found matching the search term.")
		}
	},
}

// ArchiveProjectCmd moves projects to archive
var ArchiveProjectCmd = &cobra.Command{
	Use:   "archive-project <name> [from]",
	Short: "Move project to archive",
	Args:  cobra.RangeArgs(1, 2),
	Run: func(cmd *cobra.Command, args []string) {
		projectName := args[0]
		fromDir := "forge" // default
		
		if len(args) > 1 {
			fromDir = args[1]
		}
		
		var sourceDir string
		switch fromDir {
		case "forge":
			sourceDir = forgeDir
		case "corp":
			sourceDir = corpDir
		case "labs":
			sourceDir = labDir
		default:
			utils.Red.Println("❌ Invalid source directory. Use: forge, corp, or labs")
			return
		}
		
		sourcePath := filepath.Join(sourceDir, projectName)
		archivePath := filepath.Join(archiveDir, projectName)
		
		if !utils.ProjectExists(sourceDir, projectName) {
			utils.Red.Printf("❌ Project '%s' not found in %s\n", projectName, fromDir)
			return
		}
		
		if utils.ProjectExists(archiveDir, projectName) {
			utils.Yellow.Println("⚠️  Project already exists in archive")
			return
		}
		
		if err := os.Rename(sourcePath, archivePath); err != nil {
			utils.Red.Printf("❌ Failed to archive project: %v\n", err)
			return
		}
		
		utils.Green.Printf("📦 Archived project: %s\n", projectName)
		utils.Cyan.Printf("📍 New location: %s\n", archivePath)
	},
}

func showAvailableProjects(dir, name string) {
	projects, err := utils.ListProjects(dir)
	if err != nil || len(projects) == 0 {
		utils.Yellow.Printf("No projects found in %s\n", name)
		return
	}
	
	utils.Cyan.Println("Available projects:")
	for _, project := range projects {
		fmt.Printf("  • %s\n", project)
	}
}

func init() {
	NewCmd.AddCommand(NewForgeCmd)
	NewCmd.AddCommand(NewCorpCmd)
}
