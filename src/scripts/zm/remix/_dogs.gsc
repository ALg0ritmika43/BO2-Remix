#include maps/mp/gametypes_zm/_hud_util;
#include maps/mp/zombies/_zm_utility;
#include common_scripts/utility;
#include maps/mp/_utility;
#include maps/mp/zombies/_zm_ai_dogs;

set_dog_rounds()
{
    if( !is_classic() && level.script != "zm_nuked" )
    {
        enable_dog_rounds_custom();
    }
}

enable_dog_rounds_custom()
{
    level.dog_rounds_enabled = 1;
    if ( !isDefined( level.dog_round_track_override ) )
    {
        level.dog_round_track_override = ::dog_round_tracker_override;
    }
    level thread [[ level.dog_round_track_override ]]();
}

dog_round_tracker_override()
{
    level.dog_round_count = 1;
    level.next_dog_round = 5;
    old_spawn_func = level.round_spawn_func;
    old_wait_func = level.round_wait_func;

    while ( 1 )
    {
        level waittill( "between_round_over" );

        if ( level.round_number == level.next_dog_round )
        {
            level.music_round_override = 1;

            old_spawn_func = level.round_spawn_func;
            old_wait_func = level.round_wait_func;

            dog_round_start();

            // Задаем новую логику спавна собак
            level.round_spawn_func = ::dog_round_single_spawn;

            level.next_dog_round = level.round_number + 4;
        }
        else if ( flag( "dog_round" ) )
        {
            dog_round_stop();

            // Возвращаем стандартные функции
            level.round_spawn_func = old_spawn_func;
            level.round_wait_func = old_wait_func;

            level.music_round_override = 0;
            level.dog_round_count += 1;

            // Сбрасываем флаг для спавна собак
            level.dogs_spawned = false;
        }
    }
}

dog_round_start()
{
    flag_set( "dog_round" );
    level notify( "dog_round_start" );
    level.dogs_spawned = false; // Сбрасываем флаг для нового раунда
}

dog_round_stop()
{
    flag_clear( "dog_round" );
    level notify( "dog_round_stop" );
}

// Функция для спавна собак один раз
dog_round_single_spawn()
{
    if ( !isDefined( level.dogs_spawned ) || !level.dogs_spawned )
    {
        level.dogs_spawned = true; // Устанавливаем флаг, чтобы собаки спавнились только один раз
        spawn_dogs(); // Спавн собак
    }
}

// Основная логика спавна собак
spawn_dogs()
{
    // Здесь задается логика спавна собак
    num_dogs = randomIntRange(3, 6); // Количество собак (от 3 до 5)

    for ( i = 0; i < num_dogs; i++ )
    {
        dog = spawn( "script_model", level.random_spawn_point() );
        dog.health = 100;
        dog.type = "dog";

        // Пример: Логика для атаки игрока
        dog thread dog_behavior();
    }
}

dog_behavior()
{
    self notify( "start_attack" );
    // Пример: Собаки атакуют игрока
    while ( self.health > 0 )
    {
        wait( 1 );
        self moveTo( get_closest_player(), 1 ); // Двигаемся к ближайшему игроку
    }
    self delete(); // Удаляем собаку после смерти
}

get_closest_player()
{
    closest_player = undefined;
    min_distance = 999999;

    foreach ( player in level.players )
    {
        distance = self.origin distanceTo( player.origin );
        if ( distance < min_distance )
        {
            min_distance = distance;
            closest_player = player;
        }
    }

    return closest_player;
}
