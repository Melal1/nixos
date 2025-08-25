{
services.keyd = {
  enable = true;
  keyboards = {
    default = {
      ids = [ "*" ];        # apply to all keyboards
      settings = {
        main = {
          esc = "~";        # remap Esc key to ~
        };
      };
    };
  };
};

}
