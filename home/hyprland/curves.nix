[
  {
    _args = [
      "easeOutQuint"
      {
        type = "bezier";
        points = [ [0.23 1] [0.32 1] ];
      }
    ];
  }
  {
    _args = [
      "easeInOutCubic"
      {
        type = "bezier";
        points = [ [0.65 0.05] [0.36 1] ];
      }
    ];
  }
  {
    _args = [
      "linear"
      {
        type = "bezier";
        points = [ [0 0] [1 1] ];
      }
    ];
  }
  {
    _args = [
      "almostLinear"
      {
        type = "bezier";
        points = [ [0.5 0.5] [0.75 1] ];
      }
    ];
  }
  {
    _args = [
      "quick"
      {
        type = "bezier";
        points = [ [0.15 0] [0.1 1] ];
      }
    ];
  }
  {
    _args = [
      "easy"
      {
        type = "spring";
        mass = 1;
        stiffness = 71.2633;
        dampening = 15.8273644;
      }
    ];
  }
]
