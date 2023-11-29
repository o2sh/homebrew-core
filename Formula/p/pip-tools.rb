class PipTools < Formula
  include Language::Python::Virtualenv

  desc "Locking and sync for Pip requirements files"
  homepage "https://pip-tools.readthedocs.io"
  url "https://files.pythonhosted.org/packages/fd/01/f0055058a86a888f32ac794fa68d5a25c2d2f7a3e8181474b711faaa2145/pip-tools-7.3.0.tar.gz"
  sha256 "8e9c99127fe024c025b46a0b2d15c7bd47f18f33226cf7330d35493663fc1d1d"
  license "BSD-3-Clause"

  bottle do
    rebuild 5
    sha256 cellar: :any_skip_relocation, arm64_sonoma:   "0a3aa6b5725bdfa2a46bea21df9af7634a21ef9e7dd7e9d0e060adb6be67d895"
    sha256 cellar: :any_skip_relocation, arm64_ventura:  "04b03da4f27362629b807d141e1047c6d2361b8da1599498811e58c28fc80cc5"
    sha256 cellar: :any_skip_relocation, arm64_monterey: "4c30eda80147a77de1b9f2f240fc5a914543bb0ca408dbb4ca61132205fc1ea3"
    sha256 cellar: :any_skip_relocation, sonoma:         "bd1466ef17b50690da920e625684332cf6c8ee72df6c88c57c5706dcd1a71f02"
    sha256 cellar: :any_skip_relocation, ventura:        "c4da8f78a4191fb947463e36d09d8be27fa48ace739b106b7458fa7c61b4872a"
    sha256 cellar: :any_skip_relocation, monterey:       "332350d46df9bc0d76bd43490dfd5b9f58f7e4b1d92cd536636f732df9f6f01b"
    sha256 cellar: :any_skip_relocation, x86_64_linux:   "92765b45f9e45b60d7de8d2931fc67c12b1cba7487d7b5e893a8720f53c7764c"
  end

  depends_on "python-build"
  depends_on "python-click"
  depends_on "python-packaging"
  depends_on "python-pyproject-hooks"
  depends_on "python@3.12"

  resource "wheel" do
    url "https://files.pythonhosted.org/packages/c9/3d/02a14af2b413d7abf856083f327744d286f4468365cddace393a43d9d540/wheel-0.41.1.tar.gz"
    sha256 "12b911f083e876e10c595779709f8a88a59f45aacc646492a67fe9ef796c1b47"
  end

  def install
    virtualenv_install_with_resources

    %w[pip-compile pip-sync].each do |script|
      generate_completions_from_executable(bin/script, shells: [:fish, :zsh], shell_parameter_format: :click)
    end
  end

  test do
    (testpath/"requirements.in").write <<~EOS
      pip-tools
      typing-extensions
    EOS

    compiled = shell_output("#{bin}/pip-compile requirements.in -q -o -")
    assert_match "This file is autogenerated by pip-compile", compiled
    assert_match "# via pip-tools", compiled
  end
end
