package main

type TemplateContext struct {
	Name string

	EnvProperties []EnvProperty
}

type EnvProperty struct {
	Name string
	EnvConfig
}
