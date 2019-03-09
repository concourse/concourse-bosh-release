#! /usr/bin/env ruby
#
#  unit tests for the helpers in `create_env_files.erb.tmpl`
#

#
#  paste ruby code from `create_env_files.erb.tmpl` here and run `rspec path/to/this/file`
#

#
#  below here are the unit tests
#
require "rspec"
require "json"

describe "env_file_write" do
  context "Array" do
    let(:value) {
      [
        "bar",
        ["quux", "quuux", "quuuux"],
        { "grunt" => "gorp" },
      ]
    }

    let(:expected) {
      <<~EOS
        cat > /var/vcap/jobs/{{.Name}}/config/env/MyEnv_0 <<"ENVGEN_EOF"
        bar
        ENVGEN_EOF


        cat > /var/vcap/jobs/{{.Name}}/config/env/MyEnv_1 <<"ENVGEN_EOF"
        quux
        quuux
        quuuux
        ENVGEN_EOF


        cat > /var/vcap/jobs/{{.Name}}/config/env/MyEnv_2 <<"ENVGEN_EOF"
        {"grunt":"gorp"}
        ENVGEN_EOF
      EOS
    }
    it { expect(env_file_writer(value, "MyEnv")).to eq(expected) }
  end

  context "Hash" do
    let(:value) {
      {
        "foo" => "bar",
        "baz" => ["quux", "quuux", "quuuux"],
        "thud" => { "grunt" => "gorp" },
      }
    }

    let(:expected) {
      <<~EOS
        cat > /var/vcap/jobs/{{.Name}}/config/env/MyEnv_foo <<"ENVGEN_EOF"
        bar
        ENVGEN_EOF


        cat > /var/vcap/jobs/{{.Name}}/config/env/MyEnv_baz <<"ENVGEN_EOF"
        quux
        quuux
        quuuux
        ENVGEN_EOF


        cat > /var/vcap/jobs/{{.Name}}/config/env/MyEnv_thud <<"ENVGEN_EOF"
        {"grunt":"gorp"}
        ENVGEN_EOF
      EOS
    }
    it { expect(env_file_writer(value, "MyEnv")).to eq(expected) }
  end

  context "String" do
    let(:value) { "hello there\ni am fine" }
    let(:expected) {
      <<~EOS
        cat > /var/vcap/jobs/{{.Name}}/config/env/MyEnv <<"ENVGEN_EOF"
        hello there
        i am fine
        ENVGEN_EOF

      EOS
    }
    it { expect(env_file_writer(value, "MyEnv")).to eq(expected) }
  end
end
