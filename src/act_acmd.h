//
// Created by jaystevens on 8/17/19.
//

#ifndef CIRCLEMUD_ACT_ACMD_H
#define CIRCLEMUD_ACT_ACMD_H

/** Definition of the action command, for the do_ series of in game functions.
 * This macro is placed here (for now) because it's too general of a macro
 * to be first defined in interpreter.h. The reason for using a macro is
 * to allow for easier addition of parameters to the otherwise generic and
 * static function structure. */
#define ACMD(name)  void name(struct char_data *ch, char *argument, int cmd, int subcmd)


#endif //CIRCLEMUD_ACT_ACMD_H
