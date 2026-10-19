# Python: an interpreter with the usual scientific stack for quick scripts,
# uv for real projects (`uv init`, `uv add`, `uv run`), and VSCode wired to
# the Nix-built tools instead of downloading its own.
{ pkgs, ... }:
let
  python = pkgs.python3.withPackages (
    ps: with ps; [
      numpy
      scipy
      matplotlib
      pandas
      sympy
      requests
      ipython
      ipykernel # lets the VSCode notebooks use this interpreter
      jupyter
    ]
  );
in
{
  home.packages = [
    python
    pkgs.uv
    pkgs.ruff
    pkgs.basedpyright
  ];

  # uv uses its own managed pythons only when asked; the Nix one by default
  home.sessionVariables.UV_PYTHON_PREFERENCE = "system";

  programs.vscode.profiles.default = {
    extensions = with pkgs.vscode-extensions; [
      ms-python.python
      ms-python.debugpy
      detachhead.basedpyright # types and completion (instead of Pylance)
      charliermarsh.ruff # lint + format
      ms-toolsai.jupyter
      ms-toolsai.jupyter-renderers
    ];

    userSettings = {
      "python.defaultInterpreterPath" = "${python}/bin/python3";
      # basedpyright does the language server, not Pylance
      "python.languageServer" = "None";
      "basedpyright.analysis.typeCheckingMode" = "standard";
      "basedpyright.importStrategy" = "fromEnvironment";
      "ruff.nativeServer" = "on";
      "ruff.path" = [ "${pkgs.ruff}/bin/ruff" ];
      "[python]" = {
        "editor.tabSize" = 4;
        "editor.defaultFormatter" = "charliermarsh.ruff";
        "editor.formatOnSave" = true;
        "editor.codeActionsOnSave" = {
          "source.organizeImports" = "explicit";
        };
      };
      # the .venv of a uv project is picked up automatically
      "python.terminal.activateEnvironment" = true;
    };
  };
}
