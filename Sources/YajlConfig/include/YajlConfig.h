#ifndef SWIFT_YAJL_CONFIG_H
#define SWIFT_YAJL_CONFIG_H 1

#include <CoreFoundation/CoreFoundation.h>
#include <yajl/yajl_gen.h>
#include <yajl/yajl_parse.h>

// clang-format off
CF_SWIFT_NAME(configureYajlHandle(_:option:intValue:))
// clang-format on
extern int yajl_handle_config_int(yajl_handle h, yajl_option opt, size_t value);

// clang-format off
CF_SWIFT_NAME(configureYajlGenerator(_:option:intValue:))
// clang-format on
extern int yajl_gen_config_int(yajl_gen gen, yajl_gen_option opt, size_t value);

// clang-format off
CF_SWIFT_NAME(configureYajlGenerator(_:option:stringValue:))
// clang-format on
extern int yajl_gen_config_string(yajl_gen, yajl_gen_option, const char *);

#endif /* ifndef SWIFT_YAJL_CONFIG_H */
