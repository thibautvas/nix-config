{ config, lib, pkgs, unstablePkgs, isDarwin, ... }:

let
  cmdCtrl = if isDarwin then "cmd" else "ctrl";

in {
  programs.vscode = lib.mkIf isDarwin {
    enable = true;
    package = unstablePkgs.vscode;
    profiles.default = {
      userSettings = {
        "update.mode" = "none";
        "window.restoreWindows" = "none";
        "workbench.startupEditor" = "none";
        "window.commandCenter" = false;
        "workbench.editor.editorActionsLocation" = "hidden";
        "workbench.layoutControl.enabled" = false;
        "workbench.statusBar.visible" = false;
        "workbench.activityBar.location" = "top";
        "workbench.editor.showTabs" = "none";
        "breadcrumbs.enabled" = false;
        "editor.minimap.enabled" = false;
        "editor.cursorBlinking" = "smooth";
        "debug.toolBarLocation" = "docked";
        "notebook.globalToolbar" = false;
        "notebook.cellToolbarLocation"."default" = "hidden";
        "editor.accessibilitySupport" = "off";
        "workbench.colorCustomizations" = {
          "activityBar.activeBackground" = "#004848";
          "activityBar.background" = "#004848";
          "activityBar.foreground" = "#e7e7e7";
          "activityBar.inactiveForeground" = "#e7e7e799";
          "activityBarBadge.background" = "#000000";
          "activityBarBadge.foreground" = "#e7e7e7";
          "commandCenter.border" = "#e7e7e799";
          "sash.hoverBorder" = "#004848";
          "statusBar.background" = "#001515";
          "statusBar.foreground" = "#e7e7e7";
          "statusBarItem.hoverBackground" = "#004848";
          "statusBarItem.remoteBackground" = "#001515";
          "statusBarItem.remoteForeground" = "#e7e7e7";
          "titleBar.activeBackground" = "#001515";
          "titleBar.activeForeground" = "#e7e7e7";
          "titleBar.inactiveBackground" = "#00151599";
          "titleBar.inactiveForeground" = "#e7e7e799";
        };
        "workbench.colorTheme" = "Catppuccin Macchiato";
        "workbench.editor.enablePreview" = false;
        "editor.cursorSurroundingLines" = 10;
        "editor.snippetSuggestions" = "top";
        "files.insertFinalNewline" = true;
        "editor.autoClosingQuotes" = "never";
        "editor.autoClosingBrackets" = "never";
        "[python]" = {
          "editor.formatOnSave" = true;
          "editor.defaultFormatter" = "charliermarsh.ruff";
          "editor.codeActionsOnSave"."source.fixAll" = "explicit";
        };
        "notebook.output.textLineLimit" = 40;
        "jupyter.interactiveWindow.textEditor.executeSelection" = true;
        "jupyter.interactiveWindow.viewColumn" = "beside";
        "python.terminal.activateEnvironment" = false;
        "workbench.editor.empty.hint" = "hidden";
        "terminal.integrated.initialHint" = false;
        "extensions.ignoreRecommendations" = true;
        "git.openRepositoryInParentFolders" = "never";
        "jupyter.askForKernelRestart" = false;
        "vim.smartRelativeLine" = true;
        "vim.mouseSelectionGoesIntoVisualMode" = false;
        "vim.overrideCopy" = false;
        "vim.highlightedyank.enable" = true;
        "sqltools.autoOpenSessionFiles" = false;
        "sqltools.highlightQuery" = false;
        "sqltools.queryParams.enableReplace" = true;
        "sqltools.queryParams.regex" = "\\{([\\d\\w]+)\\}|\\$\\{([\\d\\w]+)\\}|<\\[([\\d\\w\\.\\s\\[\\]]+)\\]>";
        "sqltools.results.location" = "next";
        "sqltools.defaultOpenType" = "csv";
        "sqltools.defaultExportType" = "csv";
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
          command = "notebook.clearAllCellsOutputs";
          when = "notebookEditorFocused";
        }
        {
          key = "ctrl+; ctrl+k";
          command = "jupyter.restartkernel";
          when = "notebookEditorFocused";
        }
        {
          key = "${cmdCtrl}+e ${cmdCtrl}+f";
          command = "sqltools.executeCurrentQuery";
          when = "editorTextFocus && editorLangId == 'sql' && !config.sqltools.disableChordKeyBindings";
        }
      ];
    };
  };
}
