{ config, lib, pkgs, unstablePkgs, isDarwin, ... }:

let
  cmdCtrl = if isDarwin then "cmd" else "ctrl";

in {
  programs.vscode = {
    enable = true;
    package = unstablePkgs.vscode;
    profiles.default = {
      userSettings = {
        "[python]" = {
          "editor.codeActionsOnSave"."source.fixAll" = "explicit";
          "editor.defaultFormatter" = "charliermarsh.ruff";
          "editor.formatOnSave" = true;
        };
        "[sql]" = {
          "editor.defaultFormatter" = "dorzey.vscode-sqlfluff";
          "editor.formatOnSave" = true;
        };
        "breadcrumbs.enabled" = false;
        "editor.accessibilitySupport" = "off";
        "editor.autoClosingBrackets" = "never";
        "editor.autoClosingQuotes" = "never";
        "editor.cursorBlinking" = "smooth";
        "editor.cursorSurroundingLines" = 10;
        "editor.minimap.enabled" = false;
        "extensions.ignoreRecommendations" = true;
        "files.exclude"."**/.git" = false;
        "files.insertFinalNewline" = true;
        "git.openRepositoryInParentFolders" = "never";
        "jupyter.askForKernelRestart" = false;
        "jupyter.interactiveWindow.codeLens.enable" = false;
        "jupyter.interactiveWindow.textEditor.executeSelection" = true;
        "jupyter.interactiveWindow.viewColumn" = "beside";
        "notebook.cellToolbarLocation"."default" = "hidden";
        "notebook.globalToolbar" = false;
        "notebook.output.textLineLimit" = 40;
        "python.terminal.activateEnvironment" = false;
        "sqlfluff.linter.diagnosticSeverity" = "warning";
        "sqlfluff.linter.run" = "onSave";
        "terminal.integrated.initialHint" = false;
        "update.mode" = "none";
        "vim.highlightedyank.enable" = true;
        "vim.mouseSelectionGoesIntoVisualMode" = false;
        "vim.overrideCopy" = false;
        "vim.smartRelativeLine" = true;
        "window.commandCenter" = false;
        "window.restoreWindows" = "none";
        "workbench.activityBar.location" = "top";
        "workbench.colorTheme" = "Catppuccin Macchiato";
        "workbench.editor.editorActionsLocation" = "hidden";
        "workbench.editor.empty.hint" = "hidden";
        "workbench.editor.enablePreview" = false;
        "workbench.editor.showTabs" = "none";
        "workbench.layoutControl.enabled" = false;
        "workbench.startupEditor" = "none";
        "workbench.statusBar.visible" = false;
      };

      keybindings = [
        {
          key = "tab";
          command = "-acceptSelectedSuggestion";
          when = "suggestWidgetHasFocusedSuggestion && suggestWidgetVisible && textInputFocus";
        }
        {
          key = "ctrl+y";
          command = "acceptSelectedSuggestion";
          when = "suggestWidgetHasFocusedSuggestion && suggestWidgetVisible && textInputFocus";
        }
        {
          key = "enter";
          command = "-acceptSelectedSuggestion";
          when = "acceptSuggestionOnEnter && suggestWidgetHasFocusedSuggestion && suggestWidgetVisible && suggestionMakesTextEdit && textInputFocus";
        }
        {
          key = "ctrl+l";
          command = "workbench.action.moveEditorToNextGroup";
        }
        {
          key = "ctrl+shift+l";
          command = "workbench.action.joinAllGroups";
        }
        {
          key = "${cmdCtrl}+=";
          command = "editor.action.fontZoomIn";
          when = "editorFocus";
        }
        {
          key = "${cmdCtrl}+-";
          command = "editor.action.fontZoomReset";
          when = "editorFocus";
        }
        {
          key = "ctrl+; ctrl+l";
          command = "jupyter.interactive.clearAllCells";
          when = "editorFocus";
        }
        {
          key = "ctrl+; ctrl+k";
          command = "jupyter.restartkernel";
          when = "editorFocus";
        }
        {
          key = "${cmdCtrl}+e ${cmdCtrl}+f";
          command = "sqltools.executeCurrentQuery";
          when = "editorTextFocus && editorLangId == 'sql' && !config.sqltools.disableChordKeyBindings";
        }
	{
          key = "alt+h";
          command = "workbench.action.editor.nextChange";
          when = "editorTextFocus && !textCompareEditorActive && quickDiffDecorationCount != '0'";
        }
	{
          key = "alt+shift+h";
          command = "workbench.action.editor.previousChange";
          when = "editorTextFocus && !textCompareEditorActive && quickDiffDecorationCount != '0'";
        }
	{
          key = "ctrl+shift+h";
          command = "git.stageSelectedRanges";
          when = "editorTextFocus && !operationInProgress && resourceScheme == 'file'";
        }
      ];
    };
  };
}
