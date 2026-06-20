#ifndef UTIL_H
#define UTIL_H

/*
 * util_target_name() — returns "Atari 400/800" or "Atari XL/XE"
 * util_free_ram()    — rough free RAM estimate in bytes
 */
const char   *util_target_name(void);
unsigned int  util_free_ram(void);

#endif /* UTIL_H */