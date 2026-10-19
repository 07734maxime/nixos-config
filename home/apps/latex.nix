# LaTeX: a full TeX Live, `latex-new` to start a project from ./latex/templates,
# and VSCode as the editor (LaTeX Workshop: build on save, PDF in Okular with
# SyncTeX, LTeX+ for French and English grammar).
{ pkgs, lib, ... }:
let
  texlive = pkgs.texliveFull;
  okular = "${pkgs.kdePackages.okular}/bin/okular";

  latex-new = pkgs.writeShellApplication {
    name = "latex-new";
    runtimeInputs = with pkgs; [
      coreutils
      gnused
      git
    ];
    runtimeEnv.LATEX_TEMPLATES = ./latex/templates;
    text = builtins.readFile ./latex/new.sh;
  };
in
{
  # light PDF viewer, coloured by Stylix; pages stay white (Ctrl+R: dark mode)
  programs.zathura = {
    enable = true;
    options = {
      recolor = false;
      recolor-keephue = true;
      synctex = true;
      selection-clipboard = "clipboard";
      # scrolling: bigger wheel steps, no blank "Loading..." pages, more pages cached
      scroll-step = 100;
      render-loading = false;
      page-cache-size = 30;
    };
    # j/k scroll smoothly instead of jumping
    mappings = {
      j = "scroll smooth-down";
      k = "scroll smooth-up";
    };
  };

  # Okular is the LaTeX viewer: thumbnails on the left (F7), scrollbar, reloads
  # on every build. Shift+click (browse mode) jumps back to the source in VSCode;
  # set at activation, not as a symlink, so Okular can still save its settings.
  home.activation.okularEditor = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    kwrite=${pkgs.kdePackages.kconfig}/bin/kwriteconfig6
    run $kwrite --file okularpartrc --group General --key ExternalEditor Custom
    run $kwrite --file okularpartrc --group General --key ExternalEditorCommand "code --reuse-window -g %f:%l"
  '';

  home.packages = [
    pkgs.kdePackages.okular
    texlive
    pkgs.texlab
    pkgs.tex-fmt
    latex-new
  ];

  programs.vscode.profiles.default = {
    extensions = with pkgs.vscode-extensions; [
      james-yu.latex-workshop
      ltex-plus.vscode-ltex-plus
    ];

    userSettings = {
      # latexmk follows the .latexmkrc of the project (LuaLaTeX, build/)
      "latex-workshop.latex.recipes" = [
        {
          name = "latexmk";
          tools = [ "latexmk" ];
        }
      ];
      "latex-workshop.latex.tools" = [
        {
          name = "latexmk";
          command = "${texlive}/bin/latexmk";
          args = [ "%DOC%" ];
          env = { };
        }
      ];
      "latex-workshop.latex.outDir" = "%DIR%/build";
      "latex-workshop.latex.autoBuild.run" = "onSave";
      "latex-workshop.latex.autoClean.run" = "never";
      # the PDF opens in Okular, its own niri column, reloaded on every build;
      # Ctrl+Alt+J jumps there, Shift+click in Okular jumps back to the source
      "latex-workshop.view.pdf.viewer" = "external";
      "latex-workshop.view.pdf.external.viewer.command" = okular;
      "latex-workshop.view.pdf.external.viewer.args" = [
        "--unique"
        "%PDF%"
      ];
      "latex-workshop.view.pdf.external.synctex.command" = okular;
      "latex-workshop.view.pdf.external.synctex.args" = [
        "--unique"
        "%PDF%#src:%LINE%%TEX%"
      ];
      "latex-workshop.synctex.afterBuild.enabled" = true;
      "latex-workshop.formatting.latex" = "tex-fmt";
      "latex-workshop.formatting.tex-fmt.path" = "${pkgs.tex-fmt}/bin/tex-fmt";
      "latex-workshop.message.warning.show" = false;
      "latex-workshop.intellisense.package.enabled" = true;

      "[latex]" = {
        "editor.wordWrap" = "on";
        "editor.formatOnSave" = true;
        "editor.defaultFormatter" = "James-Yu.latex-workshop";
      };

      # grammar and spelling, offline, with the Nix-built server
      "ltex.ltex-ls.path" = "${pkgs.ltex-ls-plus}";
      "ltex.language" = "fr";
      "ltex.enabled" = [
        "latex"
        "bibtex"
        "markdown"
      ];
      "ltex.additionalRules.motherTongue" = "fr";
      "ltex.checkFrequency" = "save";
    };
  };
}
