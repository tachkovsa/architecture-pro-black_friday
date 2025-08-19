# Выявление и устранение «горячих» шардов

### Метрики для мониторинга

| Метрика                  | Описание                                      | Порог для алерта                          | Инструменты для мониторинга              |
|--------------------------|-----------------------------------------------|-------------------------------------------|------------------------------------------|
| Chunk Distribution         | Количество чанков на шарде                    | Разница > 20% между шардами               | `sh.status()`, `db.chunks.find()`         |
| CPU Utilization            | Нагрузка CPU на узлах                         | > 70% более 5 минут                       | Prometheus + Node Exporter                |
| Ops/Sec                    | Операции чтения/записи в секунду              | > 10K для одного шарда                    | MongoDB Atlas / Percona PMM             |
| Lock Percentage            | Время блокировки БД                           | > 30% за 1 час                            | `db.serverStatus().locks`                 |
| Chunk Migration Rate       | Скорость миграции чанков                      | < 5 чанков/час при дисбалансе             | Balancer logs                             |
| Shard Size                 | Размер данных на шарде                        | Разница > 30% между шардами               | `db.stats()`                              |

### Механизмы автоматического перераспределения данных

#### Динамическое зонирование на основе категорий

Автоматическое выделение отдельных зон для категорий товаров с высокой нагрузкой и распределение их данных между несколькими шардами 

```MongoDB
sh.addShardToZone("shard2", "electronics");

sh.updateZoneKeyRange("mobworld.products", 
  { category: "Электроника", _id: MinKey }, 
  { category: "Электроника", _id: MaxKey }, 
  "electronics"
);
```

#### Адаптивный балансировщик чанков

Интеграция балансировщика MongoDB с алгоритмами, которые анализируют метрики и автоматически запускают миграцию чанков при превышении пороговых значений

```MongoDB
sh.startBalancer();

sh.setBalancerState(true);
sh.scheduleBalancer("00:00-03:00");
```

#### Взвешенное распределение запросов

Назначение приоритетов шардам на основе их текущей загрузки. Запросы к популярным данным перенаправляются на менее нагруженные узлы

```MongoDB
sh.setBalancerRecoveryPeriod(600);

sh.setShardDistribution( 
 { "shard1": 0.2, "shard2": 0.5, "shard3": 0.3 } 
);
```

#### Репликация "горячих" данных

Дублирование часто запрашиваемых данных на несколько шардов для распределения нагрузки чтения

```MongoDB
sh.addTagRange("mobworld.products", 
  { category: "Электроника", _id: MinKey }, 
  { category: "Электроника", _id: MaxKey }, 
  "hot_zone"
);
```

#### Гибкое масштабирование шардов

Автоматическое добавление новых шардов в кластер при росте нагрузки и их удаление при снижении спроса

```yaml
apiVersion: autoscaling/v2
kind: HorizontalPodAutoscaler
metadata:
  name: mongodb-shard-autoscaler
spec:
  scaleTargetRef:
    apiVersion: apps/v1
    kind: StatefulSet
    name: mongodb-shard
  minReplicas: 3
  maxReplicas: 10
  metrics:
  - type: Resource
    resource:
      name: cpu
      target:
        type: Utilization
        averageUtilization: 60
```