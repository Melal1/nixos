{
services.keyd = {
  enable = false;
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
