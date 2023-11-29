class GoAT120 < Formula
  desc "Open source programming language to build simple/reliable/efficient software"
  homepage "https://go.dev/"
  url "https://go.dev/dl/go1.20.11.src.tar.gz"
  mirror "https://fossies.org/linux/misc/go1.20.11.src.tar.gz"
  sha256 "d355c5ae3a8f7763c9ec9dc25153aae373958cbcb60dd09e91a8b56c7621b2fc"
  license "BSD-3-Clause"

  livecheck do
    url "https://go.dev/dl/?mode=json"
    regex(/^go[._-]?v?(1\.20(?:\.\d+)*)[._-]src\.t.+$/i)
    strategy :json do |json, regex|
      json.map do |release|
        next if release["stable"] != true
        next if release["files"].none? { |file| file["filename"].match?(regex) }

        release["version"][/(\d+(?:\.\d+)+)/, 1]
      end
    end
  end

  bottle do
    sha256 cellar: :any_skip_relocation, arm64_sonoma:   "df2b367432431611c4302e9e9f1da5b22e1827430cfa9d4903b51ab2e2114866"
    sha256 cellar: :any_skip_relocation, arm64_ventura:  "df2b367432431611c4302e9e9f1da5b22e1827430cfa9d4903b51ab2e2114866"
    sha256 cellar: :any_skip_relocation, arm64_monterey: "df2b367432431611c4302e9e9f1da5b22e1827430cfa9d4903b51ab2e2114866"
    sha256 cellar: :any_skip_relocation, sonoma:         "13308e1f4da5e7c878aad4d75b5e8b4516f0fe63c1ec23e28fe9c07c4566006a"
    sha256 cellar: :any_skip_relocation, ventura:        "13308e1f4da5e7c878aad4d75b5e8b4516f0fe63c1ec23e28fe9c07c4566006a"
    sha256 cellar: :any_skip_relocation, monterey:       "13308e1f4da5e7c878aad4d75b5e8b4516f0fe63c1ec23e28fe9c07c4566006a"
    sha256 cellar: :any_skip_relocation, x86_64_linux:   "1bf7faa652c20efae7fd98bf5b85ef0115cddf2445e5546852eb31398200c111"
  end

  keg_only :versioned_formula

  depends_on "go" => :build

  def install
    ENV["GOROOT_BOOTSTRAP"] = Formula["go"].opt_libexec

    cd "src" do
      ENV["GOROOT_FINAL"] = libexec
      # Set portable defaults for CC/CXX to be used by cgo
      with_env(CC: "cc", CXX: "c++") { system "./make.bash" }
    end

    libexec.install Dir["*"]
    bin.install_symlink Dir[libexec/"bin/go*"]

    system bin/"go", "install", "std", "cmd"

    # Remove useless files.
    # Breaks patchelf because folder contains weird debug/test files
    (libexec/"src/debug/elf/testdata").rmtree
    # Binaries built for an incompatible architecture
    (libexec/"src/runtime/pprof/testdata").rmtree
  end

  test do
    (testpath/"hello.go").write <<~EOS
      package main

      import "fmt"

      func main() {
          fmt.Println("Hello World")
      }
    EOS

    # Run go fmt check for no errors then run the program.
    # This is a a bare minimum of go working as it uses fmt, build, and run.
    system bin/"go", "fmt", "hello.go"
    assert_equal "Hello World\n", shell_output("#{bin}/go run hello.go")

    with_env(GOOS: "freebsd", GOARCH: "amd64") do
      system bin/"go", "build", "hello.go"
    end

    (testpath/"hello_cgo.go").write <<~EOS
      package main

      /*
      #include <stdlib.h>
      #include <stdio.h>
      void hello() { printf("%s\\n", "Hello from cgo!"); fflush(stdout); }
      */
      import "C"

      func main() {
          C.hello()
      }
    EOS

    # Try running a sample using cgo without CC or CXX set to ensure that the
    # toolchain's default choice of compilers work
    with_env(CC: nil, CXX: nil) do
      assert_equal "Hello from cgo!\n", shell_output("#{bin}/go run hello_cgo.go")
    end
  end
end
