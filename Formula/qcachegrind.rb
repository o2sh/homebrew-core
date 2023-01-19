class Qcachegrind < Formula
  desc "Visualize data generated by Cachegrind and Calltree"
  homepage "https://kcachegrind.github.io/"
  url "https://download.kde.org/stable/release-service/22.12.1/src/kcachegrind-22.12.1.tar.xz"
  sha256 "da8e6fcae433a49671174994a5eb24a69a42bcaa4e169ffbf5bd50d883b02f06"
  license "GPL-2.0-or-later"

  # We don't match versions like 19.07.80 or 19.07.90 where the patch number
  # is 80+ (beta) or 90+ (RC), as these aren't stable releases.
  livecheck do
    url "https://download.kde.org/stable/release-service/"
    regex(%r{href=.*?v?(\d+\.\d+\.(?:(?![89]\d)\d+)(?:\.\d+)*)/?["' >]}i)
  end

  bottle do
    sha256 cellar: :any,                 arm64_ventura:  "419a6a48cb7ab4e41455f4769e513353374e9468823e48a6fb8078a7e457e27d"
    sha256 cellar: :any,                 arm64_monterey: "419a6a48cb7ab4e41455f4769e513353374e9468823e48a6fb8078a7e457e27d"
    sha256 cellar: :any,                 arm64_big_sur:  "c019126b694414429cad8e3690916cb83f87061745d0cee86778446c1f08f4b0"
    sha256 cellar: :any,                 ventura:        "88c4b89a7a2a2300d7a8b031fd4a68740e99cf9b303be48f2cab35abac1b11ea"
    sha256 cellar: :any,                 monterey:       "88c4b89a7a2a2300d7a8b031fd4a68740e99cf9b303be48f2cab35abac1b11ea"
    sha256 cellar: :any,                 big_sur:        "8d08d7b6c8baa30601368101580773545182feb3b474487d411de5286d62709c"
    sha256 cellar: :any_skip_relocation, x86_64_linux:   "a14b7887c37d7cced43be2787eb1ea8ef94a0e62e75dea2a933aa09878a3dcec"
  end

  depends_on "graphviz"
  depends_on "qt@5"

  fails_with gcc: "5"

  def install
    args = ["-config", "release", "-spec"]
    os = OS.mac? ? "macx" : OS.kernel_name.downcase
    compiler = ENV.compiler.to_s.start_with?("gcc") ? "g++" : ENV.compiler
    arch = Hardware::CPU.intel? ? "" : "-#{Hardware::CPU.arch}"
    args << "#{os}-#{compiler}#{arch}"

    system Formula["qt@5"].opt_bin/"qmake", *args
    system "make"

    if OS.mac?
      prefix.install "qcachegrind/qcachegrind.app"
      bin.install_symlink prefix/"qcachegrind.app/Contents/MacOS/qcachegrind"
    else
      bin.install "qcachegrind/qcachegrind"
    end
  end
end
