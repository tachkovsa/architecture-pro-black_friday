# mongo-sharding

## Как запустить

Запускаем mongodb и приложение

```shell
docker compose up -d
```

Инициализируем конфигурационный сервер и шарды

```shell
./scripts/mongo-sharding-init.sh
```

## Как проверить

Запускаем вывод количества записей на шардах

```shell
./scripts/mongo-sharding-test.sh
```

Должны получить вывод следующего вида, где 508 и 492 - количество записей на шардах

```log
shard1 [direct: primary] test> switched to db somedb
shard1 [direct: primary] somedb> 508
shard1 [direct: primary] somedb>
shard2 [direct: primary] test> switched to db somedb
shard2 [direct: primary] somedb> 492
shard2 [direct: primary] somedb>
```