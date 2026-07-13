{ lib }:

[
  {
    _args = [
      (lib.generators.mkLuaInline "mod .. \" + Q\"")
      (lib.generators.mkLuaInline "hl.dsp.window.close()")
    ];
  }
  {
    _args = [
      (lib.generators.mkLuaInline "mod .. \" + D\"")
      (lib.generators.mkLuaInline "hl.dsp.exec_cmd(menu)")
    ];
  }
  {
    _args = [
      (lib.generators.mkLuaInline "mod .. \" + T\"")
      (lib.generators.mkLuaInline "hl.dsp.exec_cmd(terminal)")
    ];
  }
  {
    _args = [
      (lib.generators.mkLuaInline "mod .. \" + SHIFT + M\"")
      (lib.generators.mkLuaInline "hl.dsp.exec_cmd(\"command -v hyprshutdown >/dev/null 2>&1 && hyprshutdown || hyprctl dispatch 'hl.dsp.exit()'\")")
    ];
  }
  {
    _args = [
      (lib.generators.mkLuaInline "mod .. \" + E\"")
      (lib.generators.mkLuaInline "hl.dsp.exec_cmd(fileManager)")
    ];
  }
  {
    _args = [
      (lib.generators.mkLuaInline "mod .. \" + V\"")
      (lib.generators.mkLuaInline "hl.dsp.window.float({ action = \"toggle\" })")
    ];
  }
  {
    _args = [
      (lib.generators.mkLuaInline "mod .. \" + mouse:272\"")
      (lib.generators.mkLuaInline "hl.dsp.window.drag()")
      { mouse = true; }
    ];
  }
  {
    _args = [
      (lib.generators.mkLuaInline "mod .. \" + mouse:273\"")
      (lib.generators.mkLuaInline "hl.dsp.window.resize()")
      { mouse = true; }
    ];
  }
]
