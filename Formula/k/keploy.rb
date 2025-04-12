class Keploy < Formula
  desc "Testing Toolkit creates test-cases and data mocks from API calls, DB queries"
  homepage "https://keploy.io"
  url "https://github.com/keploy/keploy/archive/refs/tags/v2.4.18.tar.gz"
  sha256 "a0b342e25fa4cfb67859dd5677340e137321fe3322d41423efc128bbfb25bf36"
  license "Apache-2.0"
  head "https://github.com/keploy/keploy.git", branch: "main"

  bottle do
    sha256 cellar: :any_skip_relocation, arm64_sequoia: "bd19b8ceb99ec798d08464a5fd5dcfdbc4fb2e1514d14d87bce8c38ca98f215f"
    sha256 cellar: :any_skip_relocation, arm64_sonoma:  "bd19b8ceb99ec798d08464a5fd5dcfdbc4fb2e1514d14d87bce8c38ca98f215f"
    sha256 cellar: :any_skip_relocation, arm64_ventura: "bd19b8ceb99ec798d08464a5fd5dcfdbc4fb2e1514d14d87bce8c38ca98f215f"
    sha256 cellar: :any_skip_relocation, sonoma:        "e11e5bda8db8956ce2dcc6aab2232e8ef746e7fa25fc7aef355eced3ffb85581"
    sha256 cellar: :any_skip_relocation, ventura:       "e11e5bda8db8956ce2dcc6aab2232e8ef746e7fa25fc7aef355eced3ffb85581"
    sha256 cellar: :any_skip_relocation, x86_64_linux:  "8f4a9d6f5db1288bb52860654a6aa346f88a7eecb4d895084a8aa761425a259f"
  end

  depends_on "go" => :build

  def install
    system "go", "build", *std_go_args(ldflags: "-s -w -X main.version=#{version}")
  end

  test do
    system bin/"keploy", "config", "--generate", "--path", testpath
    assert_match "# Generated by Keploy", (testpath/"keploy.yml").read

    output = shell_output("#{bin}/keploy templatize --path #{testpath}")
    assert_match "No test sets found to templatize", output

    assert_match version.to_s, shell_output("#{bin}/keploy --version")
  end
end
