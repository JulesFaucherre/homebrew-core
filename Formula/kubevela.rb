class Kubevela < Formula
  desc "Application Platform based on Kubernetes and Open Application Model"
  homepage "https://kubevela.io"
  url "https://github.com/kubevela/kubevela.git",
      tag:      "v1.4.5",
      revision: "15bea4fb64173e5b3aaab4f7bb0f7874e1764d0b"
  license "Apache-2.0"
  head "https://github.com/kubevela/kubevela.git", branch: "master"

  bottle do
    sha256 cellar: :any_skip_relocation, arm64_monterey: "fccaec5fabae1a6421c461b78de0161519ec1eedd5893621355e3889c52f3134"
    sha256 cellar: :any_skip_relocation, arm64_big_sur:  "fccaec5fabae1a6421c461b78de0161519ec1eedd5893621355e3889c52f3134"
    sha256 cellar: :any_skip_relocation, monterey:       "cf42804b1c3692891a25edce8ed1562908f46497f4072ab96241dc9f2804b993"
    sha256 cellar: :any_skip_relocation, big_sur:        "cf42804b1c3692891a25edce8ed1562908f46497f4072ab96241dc9f2804b993"
    sha256 cellar: :any_skip_relocation, catalina:       "cf42804b1c3692891a25edce8ed1562908f46497f4072ab96241dc9f2804b993"
    sha256 cellar: :any_skip_relocation, x86_64_linux:   "6b172de0b78ef9b31f8e2292df811d0b01478e1c1c54cbc46add7fd0d54665ca"
  end

  depends_on "go" => :build

  def install
    ENV["CGO_ENABLED"] = "0"
    ldflags = %W[
      -s -w
      -X github.com/oam-dev/kubevela/version.VelaVersion=#{version}
      -X github.com/oam-dev/kubevela/version.GitRevision=#{Utils.git_head}
    ]

    system "go", "build", *std_go_args(output: bin/"vela", ldflags: ldflags), "./references/cmd/cli"
  end

  test do
    # Should error out as vela up need kubeconfig
    status_output = shell_output("#{bin}/vela up 2>&1", 1)
    assert_match "error: no configuration has been provided", status_output

    (testpath/"kube-config").write <<~EOS
      apiVersion: v1
      clusters:
      - cluster:
          certificate-authority-data: test
          server: http://127.0.0.1:8080
        name: test
      contexts:
      - context:
          cluster: test
          user: test
        name: test
      current-context: test
      kind: Config
      preferences: {}
      users:
      - name: test
        user:
          token: test
    EOS

    ENV["KUBECONFIG"] = testpath/"kube-config"
    version_output = shell_output("#{bin}/vela version 2>&1")
    assert_match "Version: #{version}", version_output
  end
end
