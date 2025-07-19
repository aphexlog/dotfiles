package main

import (
	"fmt"
	"os"

	"nav/internal/commands"

	"github.com/spf13/cobra"
)

var rootCmd = &cobra.Command{
	Use:   "nav",
	Short: "🚀 Smooth code navigation utility",
	Long: `A slick and intuitive CLI for navigating your coding workspace.
Organize projects into forge (personal), corp (work), labs (experiments), and archive.

Examples:
  nav forge                    # Navigate to forge directory
  nav forge myproject         # Navigate to specific project
  nav new forge myproject     # Create new personal project
  nav list                    # List all projects
  nav find search-term        # Search for projects`,
	Run: func(cmd *cobra.Command, args []string) {
		cmd.Help()
	},
}

func init() {
	rootCmd.AddCommand(commands.InitCmd)
	rootCmd.AddCommand(commands.ForgeCmd)
	rootCmd.AddCommand(commands.CorpCmd)
	rootCmd.AddCommand(commands.LabCmd)
	rootCmd.AddCommand(commands.ArchiveCmd)
	rootCmd.AddCommand(commands.NewCmd)
	rootCmd.AddCommand(commands.ListCmd)
	rootCmd.AddCommand(commands.FindCmd)
	rootCmd.AddCommand(commands.ArchiveProjectCmd)
}

func main() {
	if err := rootCmd.Execute(); err != nil {
		fmt.Println(err)
		os.Exit(1)
	}
}
