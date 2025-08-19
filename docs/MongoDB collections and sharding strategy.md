# Коллекции MongoDB и стратегия шардирования

### Коллекция `orders`

**Схема:**
```
{
  _id: ObjectId,
  user_id: UUID,
  order_date: ISODate,
  items: [{
    product_id: ObjectId,
    price: Decimal128,
    quantity: Int32
  }],
  status: String,
  total_amount: Decimal128,
  geo_zone: String
}
```
**Шард-ключ:** `{ user_id: "hashed", geo_zone: 1 }`
**Стратегия:** Hashed Sharding по `user_id` + `geo_zone`
**Обоснование:**
- Равномерное распределение заказов пользователей из разных регионов
- Избегание "горячих точек" при массовом создании заказов

**Команда для настройки:**
```
sh.shardCollection("mobworld.orders", { user_id: "hashed", geo_zone: 1 });
```

### Коллекция `products`

**Схема:**
```
{
  _id: ObjectId,
  name: String,
  category: String,
  price: Decimal128,
  stock: {
    "Moscow": Int32,
    "Ekaterinburg": Int32,
    "Kaliningrad": Int32,
    ...
  },
  attributes: {
    color: String,
    size: String,
    ...
  }
}
```

**Шард-ключ:** `{ category: 1, _id: 1 }`
**Стратегия:** Range Sharding по `category`
**Обоснование:**
- Группировка товаров одной категории на одном шарде ускоряет поиск и фильтрацию
- Распределение нагрузки при частых обновлениях остатков

**Команда для настройки:**
```
sh.shardCollection("mobworld.products", { category: 1, _id: 1 });
```

### Коллекция `carts`

**Схема:**
```
{
  _id: ObjectId,
  user_id: UUID,
  session_id: UUID,
  items: [{
    product_id: ObjectId,
    quantity: Int32
  }],
  status: String,
  created_at: ISODate,
  updated_at: ISODate,
  expires_at: ISODate
}
```

**Шард-ключ:**
- `{ session_id: "hashed" }` для гостевых сессий
- `{ user_id: "hashed" }` для пользователей

**Стратегия:** Hashed Sharding с разделением гостевых и пользовательских корзин
**Обоснование:**
- Гостевые корзины с `session_id` распределяются равномерно
- Пользовательские корзины шардируются по `user_id` для быстрого доступа
- Автоматическое удаление старых корзин через TTL индекс

**Команда для настройки:**
```
sh.shardCollection("mobworld.guest_carts", { session_id: "hashed" });
sh.shardCollection("mobworld.user_carts", { user_id: "hashed" });
```