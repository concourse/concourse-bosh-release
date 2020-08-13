package main

type TemplateContext struct {
	Name string

	EnvProperties EnvProperties
}

type EnvProperties []EnvProperty

type EnvProperty struct {
	Name string
	EnvConfig
}

func (ep EnvProperties) ForRuntime(runtime string) []EnvProperty {
	filtered := []EnvProperty{}
	for _, v := range ep {
		if v.EnvConfig.Runtime == runtime {
			filtered = append(filtered, v)
		}
	}
	return filtered
}
