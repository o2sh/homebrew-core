class Uv < Formula
  desc "Extremely fast Python package installer and resolver, written in Rust"
  homepage "https://github.com/astral-sh/uv"
  url "https://github.com/astral-sh/uv/archive/refs/tags/0.1.40.tar.gz"
  sha256 "bb72ab10d48389ade62be703839ce3ca0c7f077057ff7a76f42c87cb036c8a49"
  license any_of: ["Apache-2.0", "MIT"]
  head "https://github.com/astral-sh/uv.git", branch: "main"

  bottle do
    sha256 cellar: :any,                 arm64_sonoma:   "813cda9f4062818901a5dd0c2871a17250935695320b0004eadcb1d4af3aba42"
    sha256 cellar: :any,                 arm64_ventura:  "c0f0e63a8b9fff0da4787d8e21ba817ca40df5aa7052c2a7f28e5680eecbd842"
    sha256 cellar: :any,                 arm64_monterey: "ebb22c75fde86a338c88f10be7ca4d47ba0e3813a90ed6e26742aa5c76694b04"
    sha256 cellar: :any,                 sonoma:         "766a1427992bc78993048af68a740972e020d301957d4b6970fa8e7c9ee8cc81"
    sha256 cellar: :any,                 ventura:        "5790a762efa4decd648b9f6f266b45d9931964a04b85f269de2e759091a508ce"
    sha256 cellar: :any,                 monterey:       "fee46ff12a69a4baeb700dd08cd2cdbcfb7641dcbc398b915c708e5ea7d179c1"
    sha256 cellar: :any_skip_relocation, x86_64_linux:   "ee65f406f6dc8b25a5ad09a6f5d026995c19ecb74f40fd6411bc0fa0df28dc9f"
  end

  depends_on "pkg-config" => :build
  depends_on "rust" => :build
  depends_on "libgit2"
  depends_on "openssl@3"

  uses_from_macos "python" => :test

  on_linux do
    # On macOS, bzip2-sys will use the bundled lib as it cannot find the system or brew lib.
    # We only ship bzip2.pc on Linux which bzip2-sys needs to find library.
    depends_on "bzip2"
  end

  def install
    ENV["LIBGIT2_NO_VENDOR"] = "1"

    # Ensure that the `openssl` crate picks up the intended library.
    ENV["OPENSSL_DIR"] = Formula["openssl@3"].opt_prefix
    ENV["OPENSSL_NO_VENDOR"] = "1"

    system "cargo", "install", "--no-default-features", *std_cargo_args(path: "crates/uv")
    generate_completions_from_executable(bin/"uv", "generate-shell-completion")
  end

  def check_binary_linkage(binary, library)
    binary.dynamically_linked_libraries.any? do |dll|
      next false unless dll.start_with?(HOMEBREW_PREFIX.to_s)

      File.realpath(dll) == File.realpath(library)
    end
  end

  test do
    (testpath/"requirements.in").write <<~EOS
      requests
    EOS

    compiled = shell_output("#{bin}/uv pip compile -q requirements.in")
    assert_match "This file was autogenerated by uv", compiled
    assert_match "# via requests", compiled

    [
      Formula["libgit2"].opt_lib/shared_library("libgit2"),
      Formula["openssl@3"].opt_lib/shared_library("libssl"),
      Formula["openssl@3"].opt_lib/shared_library("libcrypto"),
    ].each do |library|
      assert check_binary_linkage(bin/"uv", library),
             "No linkage with #{library.basename}! Cargo is likely using a vendored version."
    end
  end
end
