package main

import (
	"fmt"
	"os"
	"path/filepath"
	"sort"
	"strings"
	"text/template"

	"github.com/spf13/cobra"
	"gopkg.in/yaml.v2"
)

var Job string
var Templates string

var rootCmd = &cobra.Command{
	Use: "envgen",
	Run: run,
}

func init() {
	rootCmd.Flags().StringVarP(&Job, "job", "j", "", "path to BOSH job")
	rootCmd.MarkFlagRequired("job")

	rootCmd.Flags().StringVarP(&Templates, "templates", "t", "", "directory containing additional templates")
}

func main() {
	if err := rootCmd.Execute(); err != nil {
		fmt.Fprintln(os.Stderr, err)
		os.Exit(1)
	}
}

func run(cmd *cobra.Command, args []string) {
	tmpl := template.New("root")

	if Templates != "" {
		_, err := tmpl.ParseGlob(filepath.Join(Templates, "*.tmpl"))
		failIf("failed to parse user templates", err)
	}

	jobPath := Job
	specPath := filepath.Join(Job, "spec")

	specFile, err := os.Open(specPath)
	failIf("failed to open spec", err)

	var spec Spec
	err = yaml.NewDecoder(specFile).Decode(&spec)
	failIf("failed to unmarshal spec", err)

	err = specFile.Close()
	failIf("failed to close spec", err)

	ctx := TemplateContext{
		Name: spec.Name,
	}

	for name, prop := range spec.Properties {
		if prop.Env != "" || prop.EnvFile != "" {
			ctx.EnvProperties = append(ctx.EnvProperties, EnvProperty{
				Name:      name,
				EnvConfig: prop.EnvConfig,
			})
		}

		if prop.EnvFields != nil {
			for field, cfg := range prop.EnvFields {
				ctx.EnvProperties = append(ctx.EnvProperties, EnvProperty{
					Name:      name + "." + field,
					EnvConfig: cfg,
				})
			}
		}
	}

	sort.Sort(byName(ctx.EnvProperties))

	templatesPath := filepath.Join(jobPath, "templates")

	templates, err := filepath.Glob(filepath.Join(templatesPath, "*.tmpl"))
	failIf("could not find job .tmpl files", err)

	_, err = tmpl.ParseFiles(templates...)
	failIf("failed to parse templates", err)

	for _, template := range templates {
		templateName := filepath.Base(template)

		filePath := strings.TrimSuffix(template, ".tmpl")

		file, err := os.Create(filePath)
		failIf("failed to create destination for template ("+template+")", err)

		err = tmpl.ExecuteTemplate(file, templateName, ctx)
		failIf("failed to execute template ("+template+")", err)

		err = file.Close()
		failIf("failed to close file", err)
	}
}

func failIf(msg string, err error) {
	if err != nil {
		println(msg + ": " + err.Error())
		os.Exit(1)
	}
}

type byName []EnvProperty

func (bn byName) Len() int           { return len(bn) }
func (bn byName) Less(i, j int) bool { return bn[i].Name < bn[j].Name }
func (bn byName) Swap(i, j int)      { bn[i], bn[j] = bn[j], bn[i] }
