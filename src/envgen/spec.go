package main

type Spec struct {
	Name       string              `yaml:"name"`
	Properties map[string]Property `yaml:"properties"`
}

type Property struct {
	EnvConfig `yaml:",inline"`
	EnvFields map[string]EnvConfig `yaml:"env_fields"`
}

type EnvConfig struct {
	Env     string `yaml:"env"`
	EnvFile string `yaml:"env_file"`
}
