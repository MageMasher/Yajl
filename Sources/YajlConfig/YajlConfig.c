#include "YajlConfig.h"

int yajl_handle_config_int(yajl_handle h, yajl_option opt, size_t value) {
  if (yajl_config(h, opt, (int)value)) {
    return 1;
  }

  return 0;
}

int yajl_gen_config_int(yajl_gen gen, yajl_gen_option opt, size_t value) {
  if (yajl_gen_config(gen, opt, (int)value)) {
    return 1;
  }

  return 0;
}

int yajl_gen_config_string(yajl_gen g, yajl_gen_option opt, const char *value) {
  if (yajl_gen_config(g, opt, value)) {
    return 1;
  }

  return 0;
}
