class Poppler < Formula
  desc "PDF rendering library (based on the xpdf-3.0 code base)"
  homepage "https://poppler.freedesktop.org/"
  url "https://poppler.freedesktop.org/poppler-0.50.0.tar.xz"
  sha256 "c9c93318b789d3933f6e0bad3bc65110280c28eac3f0666284bb9c9a0ab4bc36"

  bottle do
    sha256 "6e62caef27967e0a4034574bfd850f8170983c781118c99090d7241b167ce10f" => :sierra
    sha256 "a1607a3aa87bfec520b2835b7df3daaef7f569b6a5da112ca9c4c25c949657f3" => :el_capitan
    sha256 "eed10583d2b0c5fcc3665cdfdf7419b2a5f6deb6176c161ed8ae6a5aaacda38a" => :yosemite
  end

  option "with-qt5", "Build Qt5 backend"
  option "with-little-cms2", "Use color management system"

  deprecated_option "with-qt4" => "with-qt5"
  deprecated_option "with-qt" => "with-qt5"
  deprecated_option "with-lcms2" => "with-little-cms2"

  depends_on "pkg-config" => :build
  depends_on "cairo"
  depends_on "fontconfig"
  depends_on "freetype"
  depends_on "gettext"
  depends_on "glib"
  depends_on "gobject-introspection"
  depends_on "jpeg"
  depends_on "libpng"
  depends_on "libtiff"
  depends_on "openjpeg"
  depends_on "qt5" => :optional
  depends_on "little-cms2" => :optional

  conflicts_with "pdftohtml", :because => "both install `pdftohtml` binaries"

  resource "font-data" do
    url "https://poppler.freedesktop.org/poppler-data-0.4.7.tar.gz"
    sha256 "e752b0d88a7aba54574152143e7bf76436a7ef51977c55d6bd9a48dccde3a7de"
  end

  needs :cxx11 if build.with?("qt5") || MacOS.version < :mavericks

  def install
    ENV.cxx11 if build.with?("qt5") || MacOS.version < :mavericks
    ENV["LIBOPENJPEG_CFLAGS"] = "-I#{Formula["openjpeg"].opt_include}/openjpeg-2.1"

    args = %W[
      --disable-dependency-tracking
      --prefix=#{prefix}
      --enable-xpdf-headers
      --enable-poppler-glib
      --disable-gtk-test
      --enable-introspection=yes
      --disable-poppler-qt4
    ]

    if build.with? "qt5"
      args << "--enable-poppler-qt5"
    else
      args << "--disable-poppler-qt5"
    end

    args << "--enable-cms=lcms2" if build.with? "little-cms2"

    system "./configure", *args
    system "make", "install"
    resource("font-data").stage do
      system "make", "install", "prefix=#{prefix}"
    end
  end

  test do
    system "#{bin}/pdfinfo", test_fixtures("test.pdf")
  end
end
