class Tectdist < Formula
  desc "Standard-TeX-compatible TeX distribution backed by Tectonic"
  homepage "https://github.com/tmonk/tectdist"
  url "https://github.com/tmonk/tectdist/releases/download/v0.1.0/tectdist-0.1.0.tar.gz"
  sha256 "0570fa6583bdf242e36ef385f52b1c1ac36ecb564e3ec1b358c05c35198796d0"
  license "AGPL-3.0-only"

  # NOTE: for reviewers — how this formula differs from the tmonk/brew tap
  # formula (github.com/tmonk/tectdist, Formula/tectdist.rb), and why:
  #
  # * The tap formula BUNDLES biber 2.17 as a self-hosted binary resource
  #   (the official prebuilt binary matched to Tectonic 0.17's bundled
  #   biblatex 3.17).  Core formulae must build from source, so that is not
  #   possible here; instead the farm keeps `biber` as a proxy-or-stub (it
  #   forwards to a real biber found on PATH, like the poppler proxies).
  # * The tap formula REQUIRES a specific tectonic version at install time
  #   (Tectonic 0.17.x; a mismatched biber/biblatex pair silently breaks
  #   biblatex) and fails fast with instructions when brew's tectonic moves.
  #   Core formulae may not pin dependency versions, so that assertion is
  #   dropped here; see the caveats for the biblatex consequence.
  #
  # Everything else is identical: deps, the zipapp build, and the symlink
  # farm of classic TeX tool names dispatching to the single `tectdist`
  # executable.
  depends_on "ghostscript" # epstopdf / eps2eps / ps2pdf / pdfcrop
  depends_on "poppler"     # pdfinfo / pdftotext / pdfunite / ... (proxied)
  depends_on "python@3.14" # the zipapp interpreter
  depends_on "qpdf"        # proxied
  depends_on "tectonic"    # the engine — required

  def install
    python = formula_opt_bin("python@3.14")/"python3.14"
    system python, "build.py", "--python", python,
           "-o", buildpath/"dist/tectdist"
    libexec.install "dist/tectdist"

    bin.mkpath # make_symlink does not create the directory
    farm = %w[
      tectdist
      pdflatex latex xelatex lualatex platex uplatex pdftex tex etex luatex
      luahbtex dvilualatex dviluatex xetex pdfetex
      bibtex bibtex8 bibtexu biber makeindex xindy upmendex
      dvips dvipdfm dvipdfmx xdvipdfmx dvitype dvicopy dvipos dvidvi
      mktexlsr texhash mktexfmt mktexpk mktextfm fmtutil fmtutil-sys
      updmap updmap-sys texconfig tlmgr texdoc
      tftopl pltotf vftovp vptovf gftopk gftype afm2tfm otftotfm
      mf mpost mft tangle weave context texexec
      epstopdf pdfcrop
      kpsewhich latexmk
    ]
    farm.each do |name|
      (bin/name).make_symlink libexec/"tectdist"
    end
  end

  def caveats
    <<~EOS
      biblatex: Tectonic 0.17 bundles biblatex 3.17 (bcf 3.8), which pairs
      with biber 2.17.  Homebrew's core `biber` (2.21) is NOT compatible with
      that biblatex and aborts biblatex compiles.  The `biber` in this farm
      proxies to a real biber found on PATH; install a TeX Live-compatible
      biber 2.17 separately (e.g. via MacTeX/TeX Live) if you need biblatex.
      Without a compatible biber, biblatex compiles succeed but the
      bibliography is empty and citations print their raw keys.

      The full one-package version of tectdist — which bundles the matched
      biber binary and asserts the tectonic pairing at install time — is
      available from the tmonk/brew tap: `brew install tmonk/brew/tectdist`.

      The tectdist farm intentionally shadows nothing: poppler, qpdf and
      ghostscript tools come from those formulae themselves.  If another TeX
      installation already provides some of the farm names, run:
        brew link --overwrite tectdist
    EOS
  end

  test do
    assert_match "tectdist", shell_output("#{bin}/tectdist --version")
    assert_match "latexmk", shell_output("#{bin}/latexmk --version")
    # 61 farm names + the tectdist launcher link
    assert_operator Dir[bin/"*"].count, :>=, 62, "symlink farm incomplete"
  end
end
