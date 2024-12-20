#include "maps/mp/gametypes_zm/_hud_util.gsc"
#include "maps/mp/zombies/_zm_utility.gsc"
#include "common_scripts/utility.gsc"
#include "maps/mp/_utility.gsc"
#include "maps/mp/zombies/_zm_ai_dogs.gsc"

set_dog_rounds()
{
    if (!is_classic() && level.script != "zm_nuked")
    {
        enable_dog_rounds_custom();
    }
}

enable_dog_rounds_custom() //checked matches cerberus output
{
    level.dog_rounds_enabled = 1;
    if (!isDefined(level.dog_round_track_override))
    {
        level.dog_round_track_override = ::dog_round_tracker_override;
    }
    level thread [[level.dog_round_track_override]]();
}

dog_round_tracker_override() //checked changed to match cerberus output
{
    level.dog_round_count = 1;
    level.next_dog_round = 5;
    old_spawn_func = level.round_spawn_func;
    old_wait_func = level.round_wait_func;
    level.disable_dog_rounds = true; // Добавлено: отключение спавна собак
    while (1)
    {
        level waittill("between_round_over");
        if (level.round_number == level.next_dog_round)
        {
            if (level.disable_dog_rounds) // Проверка: если отключено, пропускаем
                continue;

            level.music_round_override = 1;
            old_spawn_func = level.round_spawn_func;
            old_wait_func = level.round_wait_func;
            dog_round_start();
            level.round_spawn_func = ::dog_round_spawning;
            level.next_dog_round = level.round_number + 4;
        }
        else if (flag("dog_round"))
        {
            dog_round_stop();
            level.round_spawn_func = old_spawn_func;
            level.round_wait_func = old_wait_func;
            level.music_round_override = 0;
            level.dog_round_count += 1;
        }
    }
}
