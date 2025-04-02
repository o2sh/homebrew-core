class WoodpeckerCli < Formula
  desc "CLI client for the Woodpecker Continuous Integration server"
  homepage "https://woodpecker-ci.org/"
  url "https://github.com/woodpecker-ci/woodpecker/archive/refs/tags/v3.5.0.tar.gz"
  sha256 "618a3297485c67a4c942e11ee4dfd9db8b5b2ecc340e2f47b59301f3d9e32ab1"
  license "Apache-2.0"
  head "https://github.com/woodpecker-ci/woodpecker.git", branch: "main"

  bottle do
    sha256 cellar: :any_skip_relocation, arm64_sequoia: "012aa108ed175f3e8a26035dd95cc602c6086f6131c1fc9304fc0b4aa3fa74ec"
    sha256 cellar: :any_skip_relocation, arm64_sonoma:  "012aa108ed175f3e8a26035dd95cc602c6086f6131c1fc9304fc0b4aa3fa74ec"
    sha256 cellar: :any_skip_relocation, arm64_ventura: "012aa108ed175f3e8a26035dd95cc602c6086f6131c1fc9304fc0b4aa3fa74ec"
    sha256 cellar: :any_skip_relocation, sonoma:        "a2e34cc8f203a630731655f25fc73a753befe612d2566e5029e2a1ac7aee2fbf"
    sha256 cellar: :any_skip_relocation, ventura:       "a2e34cc8f203a630731655f25fc73a753befe612d2566e5029e2a1ac7aee2fbf"
    sha256 cellar: :any_skip_relocation, x86_64_linux:  "179ddbc631e78e4ac6e4e866b1cb2ba3352c83743f4e5dded17be0b5c76266b5"
  end

  depends_on "go" => :build

  def install
    ldflags = "-s -w -X go.woodpecker-ci.org/woodpecker/v#{version.major}/version.Version=#{version}"
    system "go", "build", *std_go_args(ldflags:), "./cmd/cli"
  end

  test do
    output = shell_output("#{bin}/woodpecker-cli info 2>&1", 1)
    assert_match "woodpecker-cli is not set up", output

    output = shell_output("#{bin}/woodpecker-cli lint 2>&1", 1)
    assert_match "could not detect pipeline config", output

    assert_match version.to_s, shell_output("#{bin}/woodpecker-cli --version")
  end
end
