class Gifski < Formula
  desc "Highest-quality GIF encoder based on pngquant"
  homepage "https://gif.ski/"
  url "https://github.com/ImageOptim/gifski/archive/refs/tags/1.34.0.tar.gz"
  sha256 "c9711473615cb20d7754e8296621cdd95cc068cb04b640f391cd71f8787b692c"
  license "AGPL-3.0-only"
  revision 1

  bottle do
    rebuild 1
    sha256 cellar: :any,                 arm64_tahoe:   "e3c7358ae7bcc904cc67d92016abbe8f9861d2cec19f6cbf35110b36880bae7a"
    sha256 cellar: :any,                 arm64_sequoia: "4f666d7abb9833ab9fcbef4da60f84861e9e12a61eeaffbc2e78c63f601163b7"
    sha256 cellar: :any,                 arm64_sonoma:  "61d4c40ddadd5df8c3e98c26abd374d83d1a17a5c330072715c6127a290e6068"
    sha256 cellar: :any,                 sonoma:        "afc5d261245a11a2000c342c158eb948896a557028aa055bb078a46df3c4828f"
    sha256 cellar: :any_skip_relocation, arm64_linux:   "584afb5e1a1577e97688b89858c21d80d0e38822b373af5296473a870b58104f"
    sha256 cellar: :any_skip_relocation, x86_64_linux:  "8919e828c957d9b3d7e9c589c0398f49ddb8c84b057df791cb44e6499befcf05"
  end

  depends_on "pkgconf" => :build
  depends_on "rust" => :build
  depends_on "ffmpeg"

  uses_from_macos "llvm" => :build

  # Apply Arch Linux patch to support FFmpeg 8. Also used by Alpine Linux.
  patch do
    url "https://gitlab.archlinux.org/archlinux/packaging/packages/gifski/-/raw/592ebed61803fb8eb86fa8b5e33caec854e60ddf/ffmpeg-8.patch"
    sha256 "ce67b34864c276a87b5e8324c06297d3c52bd8fd625fd38236d3473d23513039"
    type :unofficial
  end

  # Backport FFmpeg 9 support from rust-ffmpeg and rust-ffmpeg-sys.
  # https://github.com/zmwangx/rust-ffmpeg/commit/b8cfe0600ca92caffe22d4ba95cb8ec1ea738290
  # https://github.com/zmwangx/rust-ffmpeg/commit/926f2d4c48c755b0bdd8352c87a65ae912246753
  # https://github.com/zmwangx/rust-ffmpeg-sys/commit/aff42027f62c61a95d025b714c582cfb75ed4e92
  patch :DATA

  def install
    system "cargo", "install", *std_cargo_args(features: "video")
  end

  test do
    png = test_fixtures("test.png")
    system bin/"gifski", "-o", "out.gif", png, png
    assert_path_exists testpath/"out.gif"
    refute_predicate (testpath/"out.gif").size, :zero?
  end
end

__END__
diff --git a/Cargo.lock b/Cargo.lock
index ace8e92..34a9fc6 100644
--- a/Cargo.lock
+++ b/Cargo.lock
@@ -96 +96 @@ dependencies = [
- "shlex",
+ "shlex 1.3.0",
@@ -102 +102 @@ name = "bitflags"
-version = "2.9.4"
+version = "2.13.1"
@@ -104 +104 @@ source = "registry+https://github.com/rust-lang/crates.io-index"
-checksum = "2261d10cca569e4643e526d8dc2e62e433cc8aba21ab764233731f8d369bf394"
+checksum = "b588b76d00fde79687d7646a9b5bdf3cc0f655e0bbd080335a95d7e96f3587da"
@@ -114 +114 @@ name = "cc"
-version = "1.2.39"
+version = "1.4.0"
@@ -116 +116 @@ source = "registry+https://github.com/rust-lang/crates.io-index"
-checksum = "e1354349954c6fc9cb0deab020f27f783cf0b604e8bb754dc4658ecf0d29c35f"
+checksum = "5add81bb678e6cb321aff7fa0dc7689ad82b112dbc032cea19f91d6b8e3582b9"
@@ -119 +119 @@ dependencies = [
- "shlex",
+ "shlex 2.0.1",
@@ -238,3 +238,2 @@ name = "ffmpeg-next"
-version = "8.0.0"
-source = "registry+https://github.com/rust-lang/crates.io-index"
-checksum = "d658424d233cbd993a972dd73a66ca733acd12a494c68995c9ac32ae1fe65b40"
+version = "9.0.0"
+source = "git+https://github.com/zmwangx/rust-ffmpeg?rev=926f2d4c48c755b0bdd8352c87a65ae912246753#926f2d4c48c755b0bdd8352c87a65ae912246753"
@@ -249,2 +248,2 @@ name = "ffmpeg-sys-next"
-version = "8.0.1"
-source = "git+https://github.com/zmwangx/rust-ffmpeg-sys?rev=36eca19434217b585748e0355a6d10c16deca8a2#36eca19434217b585748e0355a6d10c16deca8a2"
+version = "9.0.0"
+source = "git+https://github.com/zmwangx/rust-ffmpeg-sys#b84b275c2a0a59eaf7d487ba11cdfd5bea9583e4"
@@ -262 +261 @@ name = "find-msvc-tools"
-version = "0.1.2"
+version = "0.1.9"
@@ -264 +263 @@ source = "registry+https://github.com/rust-lang/crates.io-index"
-checksum = "1ced73b1dacfc750a6db6c0a0c3a3853c8b41997e2e2c563dc90804ae6867959"
+checksum = "5baebc0774151f905a1a2cc41989300b1e6fbb29aff0ceffa1064fdd3088d582"
@@ -613,0 +613,6 @@ checksum = "0fda2ff0d084019ba4d7c6f371c95d8fd75ce3524c3cb8fb653a3023f6323e64"
+[[package]]
+name = "shlex"
+version = "2.0.1"
+source = "registry+https://github.com/rust-lang/crates.io-index"
+checksum = "f8fadd59c855ef2080decdef8ff161eb6661b86933c9d82e5ba29dc602a55aba"
+
diff --git a/Cargo.toml b/Cargo.toml
index 9618f36..067d5ce 100644
--- a/Cargo.toml
+++ b/Cargo.toml
@@ -48 +48,3 @@ package = "ffmpeg-next"
-version = "8"
+version = "9.0.0"
+git = "https://github.com/zmwangx/rust-ffmpeg"
+rev = "926f2d4c48c755b0bdd8352c87a65ae912246753"
@@ -102,3 +103,0 @@ asset = [{from = "gifski.h"}]
-[patch.crates-io]
-# ffmpeg-sys-next does not support cross-compilation, which I use to produce binaries https://github.com/zmwangx/rust-ffmpeg-sys/pull/30
-ffmpeg-sys-next = { rev = "36eca19434217b585748e0355a6d10c16deca8a2", git = "https://github.com/zmwangx/rust-ffmpeg-sys"}
