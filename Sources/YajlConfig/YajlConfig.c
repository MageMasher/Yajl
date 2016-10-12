#include "YajlConfig.h"

int yajl_handle_config_int(yajl_handle h, yajl_option opt, int value) {
  if (yajl_config(h, opt, value)) {
    return 1;
  }

  return 0;
}
