#ifndef SWIFT_YAJL_CONFIG_H
#define SWIFT_YAJL_CONFIG_H 1

#include <CoreFoundation/CoreFoundation.h>
#include <yajl/yajl_parse.h>

// clang-format off
CF_SWIFT_NAME(configureYajlHandle(_:option:intValue:))
// clang-format on
extern int yajl_handle_config_int(yajl_handle h, yajl_option opt, int value);

#endif /* ifndef SWIFT_YAJL_CONFIG_H */
